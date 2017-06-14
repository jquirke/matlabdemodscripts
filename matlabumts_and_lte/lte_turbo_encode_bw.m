%%
% Copyright 2012 Ben Wojtowicz
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Affero General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Affero General Public License for more details.
%
%    You should have received a copy of the GNU Affero General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Function:    lte_turbo_encode
% Description: Turbo encodes data using the LTE Parallel Concatenated
%              Convolutional Code
% Inputs:      in_bits  - Input bits to turbo code
%              F        - Number of filler bits used
% Outputs:     out_bits - Turbo coded bits
% Spec:        3GPP TS 36.212 section 5.1.3.2 v10.1.0
% Notes:       Currently not handling filler bits
% Rev History: Ben Wojtowicz 02/18/2012 Created
%
function [out_bits] = lte_turbo_encode_bw(in_bits, F)
    % Determine the length of the input
    K = length(in_bits);

    % Construct z
    [z, fb_one] = constituent_encoder_bw(in_bits, K);

    % Construct x
    x = [in_bits, fb_one(K:K+3)];

    % Construct c_prime
    c_prime = internal_interleaver_bw(in_bits, K);

    % Construct z_prime
    [z_prime, x_prime] = constituent_encoder_bw(c_prime, K);

    % Construct d0
    out_bits(1,:) = [x(0+1:K-1+1), x(K+1), z(K+1+1), x_prime(K+1), z_prime(K+1+1)];

    % Construct d1
    out_bits(2,:) = [z(0+1:K-1+1), z(K+1), x(K+2+1), z_prime(K+1), x_prime(K+2+1)];

    % Construct d2
    out_bits(3,:) = [z_prime(0+1:K-1+1), x(K+1+1), z(K+2+1), x_prime(K+1+1), z_prime(K+2+1)];
end
