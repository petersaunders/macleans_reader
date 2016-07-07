# Objects for reading/writing Macleans articles

#' RSS Channel Object
MacleansRSSChannel <- setClass("MacleansRSSChannel",
                                slots = list(name    = "character",
                                             title   = "character",
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
