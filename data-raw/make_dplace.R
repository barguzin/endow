library(jsonlite)

url = 'https://raw.githubusercontent.com/D-PLACE/dplace-data/master/geo/societies_tdwg.json'
json_data <- fromJSON(file=url)

df = do.call(rbind, json_data)

df <- cbind(rownames(df), data.frame(df, row.names=NULL))

colnames(df) <- c('SiteCode', 'lat', 'code', 'lon', 'SubCont')

df$lon = as.double(df$lon)
df$lat = as.double(df$lat)
df$code = as.character(df$code)
df$SubCont = as.character(df$SubCont)

dplace = df[,c(1,4,2,3,5)]
dplace = data.frame(dplace)

usethis::use_data(dplace, overwrite = TRUE)
