# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Default login (idempotent). Dev/test only — never seed a known-password
# account into an environment that could reach production.
if Rails.env.local?
  password = ENV.fetch("SEED_ADMIN_PASSWORD", "changeme123!")
  admin = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.password = password
    u.password_confirmation = password
  end

  # Game#update_rounds_and_teams (after_save) auto-creates the default
  # number_of_rounds rounds and number_of_teams teams.
  Game.create(name: "First pubquiz", user: admin)

  # A fully populated demo game: 3 themed rounds, 10 questions each.
  #
  # Note on auto-creation: Game#after_save builds `number_of_rounds` rounds, and
  # each Round#after_create builds exactly 10 (empty) questions. So we don't create
  # rounds/questions here — we set the round titles (the theme) and fill in the
  # already-existing questions' text and answers.
  rounds = [
    {
      title: "Music",
      questions: [
        {question: "Which artist released the 1982 album *Thriller*, the best-selling album of all time?", answer: "Michael Jackson"},
        {question: "What stringed instrument does a luthier traditionally build and repair?", answer: "Stringed instruments such as the guitar or violin"},
        {question: "Freddie Mercury was the lead singer of which British rock band?", answer: "Queen"},
        {question: "How many strings does a standard violin have?", answer: "Four"},
        {question: "Which Beatles album features a zebra crossing on its cover?", answer: "Abbey Road"},
        {question: "What does the musical term 'forte' instruct a performer to do?", answer: "Play loudly"},
        {question: "Beyoncé rose to fame as a member of which girl group?", answer: "Destiny's Child"},
        {question: "Which Austrian composer wrote the opera *The Magic Flute*?", answer: "Wolfgang Amadeus Mozart"},
        {question: "What 1971 John Lennon song asks listeners to 'imagine all the people'?", answer: "Imagine"},
        {question: "Which instrument sits between the viola and the double bass in pitch?", answer: "The cello"}
      ]
    },
    {
      title: "Movies",
      questions: [
        {question: "In *The Matrix*, which coloured pill does Neo take to learn the truth?", answer: "The red pill"},
        {question: "Which 1997 film features the line 'I'm the king of the world!'?", answer: "Titanic"},
        {question: "Who directed *Jaws*, *E.T.* and *Jurassic Park*?", answer: "Steven Spielberg"},
        {question: "In *Star Wars*, what is the name of Han Solo's ship?", answer: "The Millennium Falcon"},
        {question: "Which animated film features a clownfish named Marlin searching for his son?", answer: "Finding Nemo"},
        {question: "What is the highest-grossing film franchise based on a theme-park ride?", answer: "Pirates of the Caribbean"},
        {question: "Which actor played the Joker in 2008's *The Dark Knight*?", answer: "Heath Ledger"},
        {question: "In *The Lord of the Rings*, what must be destroyed in the fires of Mount Doom?", answer: "The One Ring"},
        {question: "Which 1994 film is narrated by a man sitting on a bench with a box of chocolates?", answer: "Forrest Gump"},
        {question: "What 1993 film coined the phrase 'Life finds a way'?", answer: "Jurassic Park"}
      ]
    },
    {
      title: "Trivia",
      questions: [
        {question: "What is the capital city of Australia?", answer: "Canberra"},
        {question: "How many bones are there in the adult human body?", answer: "206"},
        {question: "Which planet in our solar system is the hottest?", answer: "Venus"},
        {question: "What is the chemical symbol for gold?", answer: "Au"},
        {question: "Which is the largest ocean on Earth?", answer: "The Pacific Ocean"},
        {question: "Who painted the *Mona Lisa*?", answer: "Leonardo da Vinci"},
        {question: "How many sides does a hexagon have?", answer: "Six"},
        {question: "What is the longest river in the world?", answer: "The Nile (or the Amazon, by some measures)"},
        {question: "In what year did the Berlin Wall fall?", answer: "1989"},
        {question: "What gas do plants primarily absorb from the atmosphere for photosynthesis?", answer: "Carbon dioxide"}
      ]
    }
  ]

  demo = Game.find_or_create_by!(name: "Themed Quiz Night", user: admin) do |g|
    g.number_of_rounds = rounds.length
    g.number_of_teams = 2
  end

  demo.rounds.order(:number).zip(rounds).each do |round, theme|
    round.update!(title: theme[:title])
    round.questions.order(:number).zip(theme[:questions]).each do |question, content|
      question.update!(content) if content
    end
  end
end
