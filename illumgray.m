
function illuminant = illumgray(varargin)

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% 
%% Description   :

%   ILLUMGRAY Illuminant estimation using the Gray World method
%
%   illuminant = ILLUMGRAY(A) estimates the illumination of the scene in
%   the input RGB image A under the assumption that the average color of
%   the scene is gray. To prevent over-exposed and under-exposed pixels
%   from skewing the estimation, the top and bottom 1% of pixels ordered by
%   brightness are excluded from the computation. The illuminant is
%   returned as a 1-by-3 vector of doubles.
%
%   illuminant = ILLUMGRAY(A,[bottomPercentile topPercentile]) specifies
%   the bottom and top percentiles to exclude from the estimation of the
%   illuminant. If a scalar value is specified, it is used for both
%   bottomPercentile and topPercentile. bottomPercentile and topPercentile
%   must both be in [0,100) and their sum cannot exceed 100. If the
%   percentiles are omitted, their values are assumed to be 1.
%
%   illuminant = ILLUMGRAY(___,Name,Value,...) specifies additional options
%   as name-value pairs:
%
%     'Mask'  -  M-by-N logical or numeric array specifying the pixels of
%                the input image A to take into consideration for the
%                estimation of the illuminant. Pixels of A corresponding to
%                zero values in the mask are excluded from the computation.
%
%                Default: true(size(A,1), size(A,2))
%
%     'Norm'  -  Scalar specifying the type of p-norm used in the
%                calculation of the average RGB value in the input image.
%                The p-norm is defined as sum(abs(x)^p)^(1/p).
%
%                Default: 1

[A,percentiles,mask,exponent] = parseInputs(varargin{:});

lowPercentile = percentiles(1);
highPercentile = percentiles(2);

numBins = 2^8;
if ~isa(A,'uint8')
    numBins = 2^16;
end

illuminant = zeros(1,3);
for k = 1:size(A,3)
    plane = A(:,:,k);
    plane = plane(mask);
    if isempty(plane)
        error(message('images:awb:maskExpectedNonZero','Mask'))
    end
    [counts, binLocations] = imhist(plane, numBins);
    
    cumhistLow = cumsum(counts);
    idxLow = find(cumhistLow > numel(plane) * lowPercentile/100,1,'first');
    minVal = binLocations(idxLow);
    
    cumhistHigh = cumsum(counts,'reverse');
    idxHigh = find(cumhistHigh > numel(plane) * highPercentile/100,1,'last');
    maxVal = binLocations(idxHigh);
    
    if isfloat(A)
        % Since the histogram has only 16 bits of precision,
        % loosen the condition to avoid excluding values that
        % would have otherwise been taken into consideration.
        epsilon = 1e-5;
        mask2 = plane <= maxVal+epsilon & plane >= minVal-epsilon;
    else
        mask2 = plane <= maxVal & plane >= minVal;
    end
    pixelValues = im2double(plane(mask2));
    illuminant(k) = norm(pixelValues, exponent) / numel(pixelValues);
end

%--------------------------------------------------------------------------
function [A,percentiles,mask,exponent] = parseInputs(varargin)

narginchk(1,6);

parser = inputParser();
parser.FunctionName = mfilename;

% A
validateImage = @(x) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateImage);

% Bottom and top percentiles to ignore
defaultPercentiles = 1;
validatePercentiles = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'real','nonsparse','nonempty','nonnan','vector','nonnegative','<',100}, ...
    mfilename,'[bottomPercentile topPercentile]',2);
parser.addOptional('percentiles', ...
    defaultPercentiles, ...
    validatePercentiles);

% NameValue 'Mask'
defaultMask = true;
validateMask = @(x) validateattributes(x, ...
    {'logical','numeric'}, ...
    {'real','nonsparse','nonempty','2d','nonnan'}, ...
    mfilename,'Mask');
parser.addParameter('Mask', ...
    defaultMask, ...
    validateMask);

% NameValue 'Norm'
defaultNorm = 1;
validateNorm = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'real','nonsparse','nonempty','nonnan','scalar','positive'}, ...
    mfilename,'Norm');
parser.addParameter('Norm', ...
    defaultNorm, ...
    validateNorm);

parser.parse(varargin{:});
inputs = parser.Results;
A           = inputs.A;
percentiles = double(inputs.percentiles);
mask        = inputs.Mask;
exponent    = double(inputs.Norm);

% Additional validation

% A must be MxNx3 RGB
validColorImage = (ndims(A) == 3) && (size(A,3) == 3);
if ~validColorImage
    error(message('images:validate:invalidRGBImage','A'));
end

if isscalar(percentiles)
    percentiles = [percentiles percentiles];
else
    validateattributes(percentiles, ...
        {'numeric'},{'vector','numel',2}, ...
        mfilename,'percentiles',2);
end

if (sum(percentiles) > 100)
    error(message('images:awb:percentilesMustNotOverlap', ...
        '[bottomPercentile topPercentile]',2, ...
        num2str(percentiles(1)), num2str(percentiles(2)), ...
        num2str(sum(percentiles))))
end

if isequal(mask, defaultMask)
    mask = true(size(A,1),size(A,2));
end

% The sizes of A and Mask must agree
if (size(A,1) ~= size(mask,1)) || (size(A,2) ~= size(mask,2))
    error(message('images:validate:unequalNumberOfRowsAndCols','A','Mask'));
end

% Convert to logical
mask = logical(mask);