library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)
library(flexdashboard)
library(knitr)



options(scipen=999)

data <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/a40c5db4-ab8a-4d71-930d-057fcaffbe17/data/latest")
# Code: select * from ethereum.core.ez_snapshot where space_id = 'poh.eth' or space_id = 'proofofhumanity.eth'

data <- rawToChar(data$content)

data <- as_tibble(fromJSON(data, flatten = TRUE))

data$PROPOSAL_START_TIME <- as_date(data$PROPOSAL_START_TIME)


### Analysis:

##Basics:
df <- data.frame(
  "Amount of proposals" = n_distinct(data$PROPOSAL_ID),
  "Amount of authors" = n_distinct(data$PROPOSAL_AUTHOR),
  "Amount of voters" = n_distinct(data$VOTER)
)


##Proposals:
proposals <- data %>%
  group_by(PROPOSAL_ID, PROPOSAL_TITLE) %>% 
  summarise(n = n(),
            date = first(PROPOSAL_START_TIME)) %>% 
  arrange(desc(n))

head(proposals, 10)

proposals %>% 
  ggplot(aes(date, n))+
  geom_line(size=1, color = "#00AFBB")+
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week", date_labels = "%b-%Y")+
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"))+
  ggtitle("Amount of voters per proposal")+
  xlab("Date")+
  ylab("Voters")



#Hip-50 (highly politicized DAO)
data %>% 
  filter(PROPOSAL_ID == '0x8935dab616d261bf36671ab44c64f11efa43dbe3d41291aa1e6e62158ce451cc') %>%
  mutate(VOTE_OPTION = as.numeric(VOTE_OPTION)) %>% 
  group_by(VOTE_OPTION) %>%  
  summarise(n = n()) %>% 
  mutate(VOTE_OPTION = case_when(
    VOTE_OPTION == 1 ~ "Accept changes",
    VOTE_OPTION == 2 ~ "Make no change"
  ))


data %>% 
  filter(PROPOSAL_ID == '0x8935dab616d261bf36671ab44c64f11efa43dbe3d41291aa1e6e62158ce451cc') %>% 
  mutate(CHOICES = as.character(CHOICES)) %>%
  select(CHOICES) %>% 
  slice_head()






#Change of Arbitrator (another example)
data %>% 
  filter(PROPOSAL_ID == '0xbd51e65898af245dfa62030c90921038b9c302346bdd149f4eefe33abe11fafe') %>%
  mutate(VOTE_OPTION = as.numeric(VOTE_OPTION)) %>% 
  group_by(VOTE_OPTION) %>%  
  summarise(n = n()) %>% 
  mutate(VOTE_OPTION = case_when(
    VOTE_OPTION == 1 ~ "Pass to Phase 3",
    VOTE_OPTION == 2 ~ "Make no change"
  ))

data %>% 
  filter(PROPOSAL_ID == '0xbd51e65898af245dfa62030c90921038b9c302346bdd149f4eefe33abe11fafe') %>% 
  mutate(CHOICES = as.character(CHOICES)) %>%
  select(CHOICES) %>% 
  slice_head()


# Technical example, also:
data %>% 
  filter(PROPOSAL_ID == 'QmZvAAvKMQ6VihJuUg2XBfZkynosMzV4aeAYAZutSsK4Kk') %>%
  mutate(VOTE_OPTION = as.numeric(VOTE_OPTION)) %>% 
  group_by(VOTE_OPTION) %>%  
  summarise(n = n()) %>% 
  mutate(VOTE_OPTION = case_when(
    VOTE_OPTION == 1 ~ "Pass to Phase 3",
    VOTE_OPTION == 2 ~ "Make no change"
  ))

data %>% 
  filter(PROPOSAL_ID == 'QmZvAAvKMQ6VihJuUg2XBfZkynosMzV4aeAYAZutSsK4Kk') %>% 
  mutate(CHOICES = as.character(CHOICES)) %>%
  select(CHOICES) %>% 
  slice_head()



##Voters:
voters <- data %>%
  group_by(VOTER) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n))

head(voters, 10)




##Authors:
authors <- data %>%
  group_by(PROPOSAL_ID, PROPOSAL_AUTHOR) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n))

authors <- authors %>%
  group_by(PROPOSAL_AUTHOR) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n))

head(authors, 10)
