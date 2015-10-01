module Ceres

export init, createproblem, problemaddresidualblock, solve, freeproblem

function init()
  ccall((:ceres_init,"libceres"), Void, ())
end
init()

function createproblem()
  return ccall( (:ceres_create_problem, "libceres"), Ptr{Uint8}, () )
end



function problemaddresidualblock(problem::Ptr{Uint8},
                                  costfunction::Ptr{Void}, # cfunction
                                  data::Array{Float64,1},
                                  lossfunction::Ptr{Void}, # cfunction
                                  lossfunctionuserdata::Array{Float64,1}, # data
                                  numresiduals::Int64,
                                  numparamblocks::Int64,
                                  parametersizes::Array{Int32,1},
                                  parameterpointers::Array{Ptr{Float64},1})

  val = ccall( (:ceres_problem_add_residual_block, "libceres"),
           Ptr{Void},
            (Ptr{Void},
             Ptr{Void},
             Ptr{Cdouble},
             Ptr{Void},
             Ptr{Cdouble},
             Cint,
             Cint,
             Ptr{Cint},
             Ptr{Void}),
            problem,
            costfunction,
            data,
            lossfunction,
            lossfunctionuserdata,
            numresiduals,
            numparamblocks,
            parametersizes,
            parameterpointers )
  return val
end

function solve(problem)
  ccall( (:ceres_solve, "libceres"), Void, (Ptr{Void},), problem )
end

function freeproblem(problem)
  ccall( (:ceres_free_problem, "libceres"), Void, (Ptr{Void},), problem )
end


end # module
