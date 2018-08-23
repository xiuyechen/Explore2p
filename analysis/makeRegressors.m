function reg = makeRegressors(h)
% this is a simple demo with a boxcar regressor, modify as needed

i_stim = h.ops.i_stim;
reg = zeros(size(h.stim));

reg(h.stim==i_stim) = 1;

reg = reg';

end