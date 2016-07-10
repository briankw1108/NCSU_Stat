nosim = 10000
outcome = replicate(nosim, sample(1:6, size = 4, replace = T))
prob_1 = mean(apply(outcome, 2, function(x) min(x) == 1))

atleast1 = vector()
for (i in 1:10000) {
        for (j in 1:24) {
                outcome = sample(1:6, size = 2, replace = T)
                if (sum(outcome) == 2) {
                        atleast1 = c(atleast1, 1)
                        break
                } else if (j == 24) {
                        atleast1 = c(atleast1, 0)
                } else {
                        next
                }
        }
}
prob_2 = mean(atleast1)