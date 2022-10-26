composition = [.15, .40, .05, .03, .02, .05, .18, .04, .02, .02, .01, .03]
recycling_rate = [0, 0.55, 0.15, .1, 0, .3, .4, .6, .75, .8, .5, 0]
ash_rate = [.08, .07, .05, .1, .15, .02, .02, 1, 1, 1, 1, .7]

print("Overall recycling rate: ", sum(composition .* recycling_rate), "\n")
print("Overall ash content: ", sum(composition .* ash_rate), "\n")
print("Ash content of recylcing residuals: ", sum(composition[recycling_rate .!= 0] .* ash_rate[recycling_rate .!= 0])/sum(composition[recycling_rate .!= 0]))