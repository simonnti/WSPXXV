require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get('/') do
  db = SQLite3::Database.new("db/posts.db")
  id = params[:id].to_i
  db.results_as_hash = true
  @posts = db.execute("SELECT * FROM posts")
  slim(:home)
end

post('/upload') do
  db = SQLite3::Database.new("db/posts.db")
  db.results_as_hash = true

  title = params[:title]
  description = params[:description]
  price = params[:price].to_f

  if params[:image] && params[:image][:tempfile] && params[:image][:filename]
    tempfile = params[:image][:tempfile]
    filename = params[:image][:filename]

    save_path = "./public/img/#{filename}"
    File.open(save_path, "wb") do |f|
      f.write(tempfile.read)
    end

    image_url = "/img/#{filename}"
  else
    image_url = nil
  end

  db.execute(
    "INSERT INTO posts (title, description, price, image_url) VALUES (?, ?, ?, ?)",
    [title, description, price, image_url]
  )

  redirect('/')
end

get('/upload') do
  slim(:upload)
end

post("/:id/return") do
    redirect('/')
end

get('/:id/post') do
  db = SQLite3::Database.new("db/posts.db")
  id = params[:id].to_i
  db.results_as_hash = true
  @posts = db.execute("SELECT * FROM posts WHERE id = ?", id).first
  slim(:post)
end