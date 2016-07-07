# Objects for reading/writing Macleans articles

#' RSS Channel Object
MacleansRSSChannel <- setClass("MacleansRSSChannel",
                                slots = list(name    = "character",
                                             url     = "character")
                                )

#' Magazine Article / Page Object
MacleansArticle <- setClass("MacleansArticle",
                            slots = list(title           = "character",
                                         description     = "character",
                                         content         = "character",
                                         creator         = "character",
                                         pubdate         = "POSIXt",
                                         categories      = "character",
                                         url             = "character",
                                         guid            = "character",
                                         comment_url     = "character",
                                         comment_count   = "integer"
                    ))

# Standard methods
#' Print method for channel object
setMethod("show", "MacleansRSSChannel",
        function(object) {
            cat("MacleansRSSChannel:", object@name, ":", object@url)
        }
)

#' Print method for article object
setMethod("show", "MacleansArticle",
        function(object) {
            DISP_WIDTH = 100
            cat("MacleansArticle:",
                    paste(rep("-", DISP_WIDTH), collapse=""),
                    strtrim(object@title, DISP_WIDTH), "", 
                    strtrim(object@description, DISP_WIDTH), "",
                    strtrim(object@content, DISP_WIDTH), "",
                    paste("Creator:", object@creator),
                    paste("Published:", object@pubdate),
                    paste("URL:", object@url),
                    paste("Comments:", object@comment_count),
                            sep="\n")
        }
)
