# This is a translation from c into julia of the curve_fitting.c example from the Ceres examples

using Ceres

# This is the equivalent of a use-defined CostFunction in the C/C++ Ceres API.
# This is passed as a callback to the Ceres C API, which internally converts
# the callback into a CostFunction.
function exponentialresidual(userdata::Ptr{Void},
                              parameters::Ptr{Ptr{Cdouble}},
                              residuals::Ptr{Cdouble},
                              jacobians::Ptr{Ptr{Cdouble}})
  measurement = convert(Ptr{Cdouble}, userdata)
  x = unsafe_load(measurement, 1) #measurement[0];
  y = unsafe_load(measurement, 2) #measurement[1];

	m = unsafe_load(unsafe_load(parameters,1),1)
	c = unsafe_load(unsafe_load(parameters,2),1)

  res = y - exp(m * x + c)
  unsafe_store!(residuals, res, 1) # residuals[0] = y - exp(m * x + c);
  if (jacobians == C_NULL)
    return convert(Cint,1)::Cint
  end
	ptr = unsafe_load(jacobians,1)
  if ptr != C_NULL
		drdm = - x * exp(m * x + c)  # dr/dm
		unsafe_store!(ptr, drdm, 1)
  end
	ptr = unsafe_load(jacobians,2)
  if ptr != C_NULL
		drdc = - exp(m * x + c) # dr/dc
    unsafe_store!(ptr, drdc, 1)  
  end
  return convert(Cint,1)::Cint
end

# get a c function pointer
const expres = cfunction(exponentialresidual,
                         Cint,
                         (Ptr{Void},
                          Ptr{Ptr{Cdouble}},
                          Ptr{Cdouble},
                          Ptr{Ptr{Cdouble}}))

#function example_curve_fitting()
data = [
    0.000000e+00, 1.133898e+00,
  7.500000e-02, 1.334902e+00,
  1.500000e-01, 1.213546e+00,
  2.250000e-01, 1.252016e+00,
  3.000000e-01, 1.392265e+00,
  3.750000e-01, 1.314458e+00,
  4.500000e-01, 1.472541e+00,
  5.250000e-01, 1.536218e+00,
  6.000000e-01, 1.355679e+00,
  6.750000e-01, 1.463566e+00,
  7.500000e-01, 1.490201e+00,
  8.250000e-01, 1.658699e+00,
  9.000000e-01, 1.067574e+00,
  9.750000e-01, 1.464629e+00,
  1.050000e+00, 1.402653e+00,
  1.125000e+00, 1.713141e+00,
  1.200000e+00, 1.527021e+00,
  1.275000e+00, 1.702632e+00,
  1.350000e+00, 1.423899e+00,
  1.425000e+00, 1.543078e+00,
  1.500000e+00, 1.664015e+00,
  1.575000e+00, 1.732484e+00,
  1.650000e+00, 1.543296e+00,
  1.725000e+00, 1.959523e+00,
  1.800000e+00, 1.685132e+00,
  1.875000e+00, 1.951791e+00,
  1.950000e+00, 2.095346e+00,
  2.025000e+00, 2.361460e+00,
  2.100000e+00, 2.169119e+00,
  2.175000e+00, 2.061745e+00,
  2.250000e+00, 2.178641e+00,
  2.325000e+00, 2.104346e+00,
  2.400000e+00, 2.584470e+00,
  2.475000e+00, 1.914158e+00,
  2.550000e+00, 2.368375e+00,
  2.625000e+00, 2.686125e+00,
  2.700000e+00, 2.712395e+00,
  2.775000e+00, 2.499511e+00,
  2.850000e+00, 2.558897e+00,
  2.925000e+00, 2.309154e+00,
  3.000000e+00, 2.869503e+00,
  3.075000e+00, 3.116645e+00,
  3.150000e+00, 3.094907e+00,
  3.225000e+00, 2.471759e+00,
  3.300000e+00, 3.017131e+00,
  3.375000e+00, 3.232381e+00,
  3.450000e+00, 2.944596e+00,
  3.525000e+00, 3.385343e+00,
  3.600000e+00, 3.199826e+00,
  3.675000e+00, 3.423039e+00,
  3.750000e+00, 3.621552e+00,
  3.825000e+00, 3.559255e+00,
  3.900000e+00, 3.530713e+00,
  3.975000e+00, 3.561766e+00,
  4.050000e+00, 3.544574e+00,
  4.125000e+00, 3.867945e+00,
  4.200000e+00, 4.049776e+00,
  4.275000e+00, 3.885601e+00,
  4.350000e+00, 4.110505e+00,
  4.425000e+00, 4.345320e+00,
  4.500000e+00, 4.161241e+00,
  4.575000e+00, 4.363407e+00,
  4.650000e+00, 4.161576e+00,
  4.725000e+00, 4.619728e+00,
  4.800000e+00, 4.737410e+00,
  4.875000e+00, 4.727863e+00,
  4.950000e+00, 4.669206e+00
  ]
num_observations = div(length(data),2)

problem = createproblem()

parametersizes = ones(Int32, 2)

m = Cdouble[0.0]
c = Cdouble[0.0]
parameterpointers = [convert(Ptr{Cdouble},m),convert(Ptr{Cdouble},c)]

# make sure you can treat them like pointers:
unsafe_store!(parameterpointers[1], 0.0::Cdouble, 1)
unsafe_store!(parameterpointers[2], 0.0::Cdouble, 1)

for i=0:num_observations-1
  problemaddresidualblock(problem,
                          expres,   # Cost function
                          data[(2*i)+1:(2*i)+2], # Points to the (x,y) measurement
                          C_NULL,                  # No loss function 
                          zeros(Float64,1),                  # No loss function user data
                          1,                     # Number of residuals
                          2,                     # Number of parameter blocks
                          parametersizes,
                          parameterpointers)
end

solve(problem)
freeproblem(problem)
