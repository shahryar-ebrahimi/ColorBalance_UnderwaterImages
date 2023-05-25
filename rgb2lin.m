
function B = rgb2lin(varargin)

%% Authors       : Shahryar Ebrahimi      &   Mohsen Keshtkar
%% S.N.          : 810196093              &   810196291
%% Mail          : shr.ebrahimi@ut.ac.ir  &   mohsen.keshtkar@ut.ac.ir
%% Course Title  : Digital Image Processing (DIP)
%% Paper Title   : Color Balance and Fusion for Underwater Image Enhancement
%% Date Modified : Monday, June 11, 2018
%% 
%% Description   :

%   RGB2LIN Linearize gamma-corrected sRGB or Adobe RGB (1998) values
%
%   B = RGB2LIN(A) undoes the gamma correction of the sRGB values in matrix
%   A so that B contains linear RGB values. To linearize Adobe RGB (1998)
%   inputs, use the 'ColorSpace' name-value pair.
%
%   B = RGB2LIN(___,Name,Value,...) specifies additional options as
%   name-value pairs:
%
%     'ColorSpace'  -  Color space of the input image:
%                      'srgb' (default) | 'adobe-rgb-1998'
%
%                      Default: 'srgb'
%
%     'OutputType'  -  Data type of the returned RGB values:
%                      'double' | 'single' | 'uint8' | 'uint16'
%
%                      Default: class(A)
%
%   

[A,colorSpace,outputType] = parseInputs(varargin{:});

% Convert to floating point for the conversion
if ~isa(A,'double')
    A = im2single(A);
end

if strcmp(colorSpace, 'srgb')
    B = sRGBToLinearRGB(A);
else
    B = adobeRGBToLinearRGB(A);
end

% Convert to the desired output type
convert = str2func(['im2' outputType]);
B = convert(B);

%--------------------------------------------------------------------------
function y = sRGBToLinearRGB(x)
% Curve parameters
gamma = cast(2.4,'like',x);
a     = cast(1/1.055,'like',x);
b     = cast(0.055/1.055,'like',x);
c     = cast(1/12.92,'like',x);
d     = cast(0.04045,'like',x);

in_sign = -2 * (x < 0) + 1;
x = abs(x);

lin_range = (x < d);
gamma_range = ~lin_range;

y = zeros(size(x),'like',x);

y(gamma_range) = exp(gamma .* log(a * x(gamma_range) + b));
y(lin_range) = c * x(lin_range);

y = y .* in_sign;

%--------------------------------------------------------------------------
function y = adobeRGBToLinearRGB(x)
gamma = cast(2.19921875,'like',x);
y = x .^ gamma;

%--------------------------------------------------------------------------
function [A,colorSpace,outputType] = parseInputs(varargin)

narginchk(1,5);

parser = inputParser();
parser.FunctionName = mfilename;

% A
validateImage = @(x) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateImage);

% NameValue 'ColorSpace': 'srgb' or 'adobe-rgb-1998'
defaultColorSpace = 'srgb';
validateChar = @(x) validateattributes(x, ...
    {'char','string'}, ...
    {'scalartext'}, ...
    mfilename, 'ColorSpace');
parser.addParameter('ColorSpace', ...
    defaultColorSpace, ...
    validateChar);

% NameValue 'OutputType': 'single', 'double', 'uint8', 'uint16'
defaultOutputType = -1;
parser.addParameter('OutputType', ...
    defaultOutputType, ...
    validateChar);

parser.parse(varargin{:});
inputs = parser.Results;
A = inputs.A;
colorSpace = inputs.ColorSpace;
outputType = inputs.OutputType;

if isequal(outputType, defaultOutputType)
    outputType = class(A);
end

% Additional validation
colorSpace = validatestring( ...
    colorSpace, ...
    {'srgb','adobe-rgb-1998'}, ...
    mfilename, 'ColorSpace');

outputType = validatestring( ...
    outputType, ...
    {'single','double','uint8','uint16'}, ...
    mfilename, 'OutputType');
