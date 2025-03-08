# set current directory use which the resource of data for analysis is store in this directory
setwd("~/Master in Information Technology/Fourth Semester/IT380 - Introduction to Data Mining using R/Mini capstone/Minicapstone-decision-tree-using-R/Peromingan - mini capstone")

# install needed packages for running some codes
install.packages("tm")
install.packages("SnowballC")
install.packages("stringr")
install.packages("arules")
install.packages("dplyr")
install.packages("RMySQL")
install.packages("data.tree")
install.packages("rpart")
install.packages("rpart.plot")
install.packages("RWeka")

# use library of installed packages
library('tm')
library('SnowballC')
library('stringr')
library('arules')
library("dplyr")
library('RMySQL')
library("data.tree")
library("rpart")
library("rpart.plot")
library("RWeka")

# TRACKS
# read data from file
unique_tracks <- read.csv("unique_tracks.csv", header=FALSE, sep=",", stringsAsFactors=FALSE)
# assign names to columns
colnames(unique_tracks)<-c('track_id','song_id','artist_name','song_title')
# view data
View(unique_tracks)

# ARTIST
# read data from file
unique_artists <- read.csv("unique_artists.csv", header=FALSE, sep=",", stringsAsFactors=FALSE)
# assign names to columns
colnames(unique_artists)<-c('artist_id','artist_mbid','track_id','artist_name')
# view data
View(unique_artists)

# JAM 
# read data from file
jam <- read.csv("jam_to_msd.csv", header=FALSE, sep=",", stringsAsFactors=FALSE)
colnames(jam)<-c('user_id','track_id')
View(jam)

# SONG DETAILS
# read data from file
song_dataset <- read.csv("song_dataset.csv", header=TRUE, sep=",", stringsAsFactors=FALSE)
# view data 
View(song_dataset)
# Select column names to be drop/remove
drop_song_dataset <- c("X","analyzer_version","artist_7digitalid","artist_latitude","artist_location","artist_longitude","artist_playmeid","genre","idx_artist_terms","idx_similar_artists","release","release_7digitalid","track_7digitalid")
# remove/drop selected column names
s = song_dataset[,!(names(song_dataset) %in% drop_song_dataset)]
# view the result of assing variable s
View(s)

# load data from song_dataset2 file
song_dataset2 <- read.csv("song_dataset2.csv", header=TRUE, sep=",", stringsAsFactors=FALSE)
# view loaded data from song_dataset2.csv which is assign to variable song_dataset2
View(song_dataset2)
# Select column names to drop/remove
drop_song_dataset2 <- c("X","artist.7digitalid","analysis.sample.rate","artist.playmeid","danceability","end.of.fade.in","energy","key","key.confidence","mode","mode.confidence","release.7digitalid","start.of.fade.out","tempo","time.signature","time.signature.confidence")
# remove/drop selected columns names
s2 = song_dataset2[,!(names(song_dataset2) %in% drop_song_dataset2)]
# rename column names
s2 = rename(s2, song_id = 'song.id', artist_familiarity = 'artist.familiarity', song_hotttnesss = 'song.hotttnesss')
# view result data
View(s2)

# connect to database song_db
song_db <-dbConnect(MySQL(), user="root", password="peromingan", host="35.224.141.246")
#dbSendQuery(song_db, "DROP DATABASE song_db IF EXISTS;")
#dbSendQuery(song_db, "CREATE DATABASE song_db")
dbSendQuery(song_db, "USE song_db")

# TRACKS
# create table unique_tracks to database song_db
dbWriteTable(song_db, name="unique_tracks", unique_tracks, append=TRUE)
dbGetQuery(song_db, "select * from unique_tracks")

# ARTIST
# create table unique_artists to database song_db
dbWriteTable(song_db, name="unique_artists", unique_artists, append=TRUE)
dbGetQuery(song_db, "select * from unique_artists")

# JAM
# create table jam to database song_db
dbWriteTable(song_db, name="jam", jam, append=TRUE)
dbGetQuery(song_db, "select * from jam")

# SONG_DATASET
# create table song_dataset to database song_db
dbWriteTable(song_db, name="song_dataset", s, append=TRUE)
dbGetQuery(song_db, "select * from song_dataset")

# SONG_DATASET2
# create table song_dataset2 to database song_db
dbWriteTable(song_db, name="song_dataset2", s2, append=TRUE)
dbGetQuery(song_db, "select * from song_dataset2")

# Select user_id, track_id, song_id, artist_id, year in multitple tables using union
dbGetQuery(song_db, "(select * from jam AS j JOIN unique_tracks AS ut ON ut.track_id = j.track_id) 
                      JOIN 
                     (select song_dataset.song_id, song_dataset.artist_id, song_dataset.artist_name from song_dataset AS sd JOIN song_dataset2 AS sd2 ON sd2.song_id = sd.song_id)
                      JOIN
                      (select ua.artist_id, ua.track_id, ua.artist_name from unique_artists AS ua)")

a <- dbGetQuery(song_db, "select song_id, year from song_dataset2")
