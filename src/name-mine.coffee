
nextName = 0
module.exports = nameMine = {
  getName:(n = nextName)->
    nextName = n if n >nextName
    limit = nameMine.names.length
    nameId = (nextName % limit)
    howMany = 1+((nextName- nameId) / limit)
    nextName++
    value = []
    while howMany--
      value.push nameMine.names[nameId]
      nameId += howMany *2
      nameId %= limit
    return value.join ' '
  
  names:[
    "James","Mary",
    "John","Patricia",
    "Robert","Jennifer",
    "Michael","Elizabeth",
    "William","Linda",
    "David","Barbara",
    "Richard","Susan",
    "Joseph","Jessica",
    "Thomas","Margaret",
    "Charles","Sarah",
    "Christopher","Karen",
    "Daniel","Nancy",
    "Matthew","Betty",
    "Anthony","Lisa",
    "Donald","Dorothy",
    "Mark","Sandra",
    "Paul","Ashley",
    "Steven","Kimberly",
    "Andrew","Donna",
    "Kenneth","Carol",
    "George","Michelle",
    "Joshua","Emily",
    "Kevin","Amanda",
    "Brian","Helen",
    "Edward","Melissa",
    "Ronald","Deborah",
    "Timothy","Stephanie",
    "Jason","Laura",
    "Jeffrey","Rebecca",
    "Ryan","Sharon",
    "Gary","Cynthia",
    "Jacob","Kathleen",
    "Nicholas","Amy",
    "Eric","Shirley",
    "Stephen","Anna",
    "Jonathan","Angela",
    "Larry","Ruth",
    "Justin","Brenda",
    "Scott","Pamela",
    "Frank","Nicole",
    "Brandon","Katherine",
    "Raymond","Virginia",
    "Gregory","Catherine",
    "Benjamin","Christine",
    "Samuel","Samantha",
    "Patrick","Debra",
    "Alexander","Janet",
    "Jack","Rachel",
    "Dennis","Carolyn",
    "Jerry","Emma",
    "Tyler","Maria",
    "Aaron","Heather",
    "Henry","Diane",
    "Douglas","Julie",
    "Jose","Joyce",
    "Peter","Evelyn",
    "Adam","Frances",
    "Zachary","Joan",
    "Nathan","Christina",
    "Walter","Kelly",
    "Harold","Victoria",
    "Kyle","Lauren",
    "Carl","Martha",
    "Arthur","Judith",
    "Gerald","Cheryl",
    "Roger","Megan",
    "Keith","Andrea",
    "Jeremy","Ann",
    "Terry","Alice",
    "Lawrence","Jean",
    "Sean","Doris",
    "Christian","Jacqueline",
    "Albert","Kathryn",
    "Joe","Hannah",
    "Ethan","Olivia",
    "Austin","Gloria",
    "Jesse","Marie",
    "Willie","Teresa",
    "Billy","Sara",
    "Bryan","Janice",
    "Bruce","Julia",
    "Jordan","Grace",
    "Ralph","Judy",
    "Roy","Theresa",
    "Noah","Rose",
    "Dylan","Beverly",
    "Eugene","Denise",
    "Wayne","Marilyn",
    "Alan","Amber",
    "Juan","Madison",
    "Louis","Danielle",
    "Russell","Brittany",
    "Gabriel","Diana",
    "Randy","Abigail",
    "Philip","Jane",
    "Harry","Natalie",
    "Vincent","Lori",
    "Bobby","Tiffany",
    "Johnny","Alexis",
    "Logan","Kayla",
    ]
}

#for i in [1 ... 347] by 17
#  console.log i,nameMine.getName(i)
#for i in [0 ... 1000] by 100
#  console.log i,nameMine.getName(i)
#i=5000
#console.log i,nameMine.getName(i)