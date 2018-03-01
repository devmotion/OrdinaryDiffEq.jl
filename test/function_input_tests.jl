using OrdinaryDiffEq
f_2dlinear = (du,u,p,t) -> du.=1.01u
p = [1.0,2.0]
prob = ODEProblem(f_2dlinear,(p,t0)->p,(0.0,1.0),p)
sol = solve(prob,Tsit5())
