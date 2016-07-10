suppressMessages(library(ggplot2))
library(plyr)
#create a function to calculate the jackknife estimate.
jkKnife = function (y, fcn) {
        n = length(y)
        allheldout = vector()
        for (i in 1:n) {
                oneheldout = fcn(y[-i])
                allheldout = c(allheldout, oneheldout)
        }
        jk_estimate = n * fcn(y) - (n - 1) * mean(allheldout)
        return(jk_estimate)
} 

#create a function to calculate the coeffient of variance
cv = function(y) {
        c.var = sd(y) / abs(mean(y))
        return(c.var)
}

#create a function to compare estimates compared to theoritical value to see how jackknife reduces bias
cv.bias.rdct = function (nsim, n, u, ...) {
        #generate normal random samples with defined mean and standard deviation
        samp = replicate(nsim, rexp(n, rate = 1 / u))
        #calculate theoritical cv
        coef.var = sqrt(1 / (u^2)) / abs(1 / u) #coeffient of variance of exponential distribution is always 1. 
                                                #with standard deviation = sqrt(u^-2) and mean = u^-1
        
        #calculate cv directly from samples and its standard error of its sample mean distribution
        cv.sample = apply(samp, 2, cv)
        cv.sample.mean = mean(cv.sample)
        cv.sample.se = sd(cv.sample) / sqrt(nsim)
        
        #calculate jackknife estimate of cv and its standard error of its jackknife sample mean distribution
        cv.sample.jackknife = apply(samp, 2, jkKnife, fcn = cv)
        cv.sample.jackknife.mean = mean(cv.sample.jackknife)
        cv.sample.jackknife.se = sd(cv.sample.jackknife) / sqrt(nsim)
        bias = cv.sample.mean - cv.sample.jackknife.mean
        
        #print results
        cat(paste(" exponential data with cv = ", coef.var, " sample CV \n", sep = ""))
        cat(paste("mean of CVs = ", cv.sample.mean, "SE = ", cv.sample.se, "\n"))
        cat(paste(" exponential data with cv = ", coef.var, " jackknife CV \n", sep = ""))
        cat(paste("mean of CVs = ", cv.sample.jackknife.mean, "SE = ", cv.sample.jackknife.se, "\n"))
        cat(paste(" jackknife bias = ", bias, sep = ""))
        
        #preprocess data set for plotting
        a = data.frame(x = cv.sample, group = "cv.sample")
        b = data.frame(x = cv.sample.jackknife, group = "cv.jackknife")
        data = rbind(a, b)
        mdata = ddply(data, "group", summarise, mean.cv = mean(x))
        #plot histograms and their estimates(means of sample mean distributions)
        g = ggplot(data, aes(x, fill = group)) +
                geom_histogram(alpha = 0.3, position = "identity", ...) + 
                geom_vline(data = mdata, aes(xintercept = mean.cv, colour = group), linetype = "dashed", size = 1) +
                ggtitle("Histograms of CV Sample Mean") + 
                xlab("Coefficient of Variance Estimate")
        windows()
        suppressMessages(print(g))
}
