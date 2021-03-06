# Solve the Landau-Zener problem i ψ' = H(t) ψ, with H(t) = [t 1;1 -t]

using Base.Test
using StaticArrays
using OrdinaryDiffEq, DiffEqBase

gc()
H(t) = -im*(@SMatrix [t 1;1 -t])

fun(ψ,p,t) = H(t)*ψ
fun_inplace(dψ,ψ,p,t) = (dψ .= H(t)*ψ)

T = 0.1
tspan = (0,T)
explicit = [Midpoint(),RK4(),DP5(),Tsit5(),Vern7()]
implicit_autodiff = [ImplicitEuler(),Trapezoid(),Kvaerno3(),Rosenbrock23()]
implicit_noautodiff = [ImplicitEuler(autodiff=false),Trapezoid(autodiff=false),Kvaerno3(autodiff=false),Rosenbrock23(autodiff=false)]

println("Explicit")
for alg in explicit
    for f in (fun, fun_inplace)
        ψ0 = [1.0+0.0im; 0.0]
        prob = ODEProblem(f,ψ0,(-T,T))
        sol = solve(prob,alg)
        @test abs(norm(sol(T)) - 1.0) < 1e-2
    end
    ψ0 = @SArray [1.0+0.0im; 0.0]
    prob = ODEProblem(fun,ψ0,(-T,T))
    sol = solve(prob,alg)
    @test abs(norm(sol(T)) - 1.0) < 1e-2
end

println("Implicit Autodiff")
@test_broken begin
    for alg in implicit_autodiff
        for f in (fun, fun_inplace)
            ψ0 = [1.0+0.0im; 0.0]
            prob = ODEProblem(f,ψ0,(-T,T))
            sol = solve(prob,alg)
            @test abs(norm(sol(T)) - 1.0) < 1e-2
        end
        ψ0 = @SArray [1.0+0.0im; 0.0]
        prob = ODEProblem(fun,ψ0,(-T,T))
        sol = solve(prob,alg)
        @test abs(norm(sol(T)) - 1.0) < 1e-2
    end
end

println("Implicit Finite Diff")
for alg in implicit_noautodiff
    ψ0 = [1.0+0.0im; 0.0]
    prob = ODEProblem(fun_inplace,ψ0,(-T,T))
    sol = solve(prob,alg)
    @test abs(norm(sol(T)) - 1.0) < 1e-2
end

println("Implicit Finite Diff Out-of-place")
@test_broken begin
    for alg in implicit_noautodiff
        ψ0 = [1.0+0.0im; 0.0]
        prob = ODEProblem(fun,ψ0,(-T,T))
        sol = solve(prob,alg)
        @test abs(norm(sol(T)) - 1.0) < 1e-2

        ψ0 = @SArray [1.0+0.0im; 0.0]
        prob = ODEProblem(fun,ψ0,(-T,T))
        sol = solve(prob,alg)
        @test abs(norm(sol(T)) - 1.0) < 1e-2
    end
end
