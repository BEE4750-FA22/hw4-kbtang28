using JuMP
using Cbc

composition = [.15, .40, .05, .03, .02, .05, .18, .04, .02, .02, .01, .03]
recycling_rate = [0, 0.55, 0.15, .1, 0, .3, .4, .6, .75, .8, .5, 0]
ash_rate = [.08, .07, .05, .1, .15, .02, .02, 1, 1, 1, 1, .7]

overall_recycling = sum(composition .* recycling_rate)
overall_ash = sum(composition .* ash_rate)
recycled_ash = sum(composition.*(1 .- recycling_rate).*ash_rate)/sum(composition.*(1 .- recycling_rate))

print("Overall recycling rate: ", overall_recycling, "\n")
print("Overall ash content: ", overall_ash, "\n")
print("Ash content of recylcing residuals: ", recycled_ash)

waste = Model(Cbc.Optimizer)
I = 1:2 # number of cities
J = 1:3 # number of disposal sites

@variable(waste, W[i in I, j in J] >= 0)
@variable(waste, R[k in J, j in J] >= 0)
@variable(waste, Y[j in J], Bin)

# @objective(waste, Min, sum([82.5 31.5 95; 75 46.5 87.5].*W) + sum([0 0 77; 82.5 0 98; 0 0 0].*R) + sum([2500 1500 2000].*Y)) # original
@objective(waste, Min, sum([105 34 110; 95 54 100].*W) + sum([0 0 86; 105 0 114; 0 0 0].*R) + sum([2500 1500 2000].*Y)) # carbon tax adjusted


city_out = [100; 170]

@constraint(waste, city[i in I], sum(W[i, :]) == city_out[i])
@constraint(waste, wte, W[1, 1] + W[2, 1] + R[2, 1] <= 150)
@constraint(waste, mrf, W[1, 2] + W[2, 2] <= 350)
@constraint(waste, lf, W[1, 3] + W[2, 3] + R[1, 3] + R[2, 3] <= 200)
@constraint(waste, resid1, R[2, 1] + R[2, 3] == (1-overall_recycling)*(W[1, 2] + W[2, 2]))
@constraint(waste, resid2, R[1, 3] == overall_ash*(W[1, 1] + W[2, 1]) + recycled_ash*R[2, 1])
@constraint(waste, noresids, sum(R[j, j] for j in J) + R[1, 2] + R[3, 1] + R[3, 2] == 0)
@constraint(waste, commit1, !Y[1] => {W[1, 1] + W[2, 1] + R[2, 1] == 0})
@constraint(waste, commit2, !Y[2] => {W[1, 2] + W[2, 2] == 0})
@constraint(waste, commit3, Y[3] == 1)

set_silent(waste)
optimize!(waste)