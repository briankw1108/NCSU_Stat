dice_roll = function(n, nsim, ...) {
        suppressMessages(library(ggplot2))
        plot = function(data) {
                g = ggplot(data, aes(data[,1]))
                g = g + geom_histogram(...) + 
                        ggtitle(paste("Histogram of Sum of Rolling ", n, " dice", sep = "")) +
                        xlab(paste("Sum of Rolling ", n, " dice", sep = "")) +
                        ylab("Frequecy")
                suppressMessages(print(g))
                epv = mean(sumDice[,1])
                print(paste("The expected value of rolling ", n, " dice is ", epv, sep = ""))
        }
        output = replicate(nsim, sample(1:6, n, replace = T))
        if (n > 1) {
                sumDice = as.data.frame(apply(output, 2, sum))
                cname = "die_1"
                for (i in 2:n) cname = c(cname, paste("die_", i, sep = ""))
                row.names(output) = cname
                plot(sumDice)
                return(as.data.frame(t(output)))
        } else {
                sumDice = as.data.frame(output)
                output = data.frame(die_1 = output)
                plot(sumDice)
                return(output)
        }
}