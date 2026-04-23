require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

before do
  @db = SQLite3::Database.new("db/database.db")
  @db.results_as_hash = true
end

before '/upload' do
  require_login
end

before '/myads*' do
  require_login
end

before %r{/\d+/update} do
  require_login
end

helpers do
  def current_user
    return nil unless session[:user_id]

    @current_user ||= @db.execute(
      "SELECT * FROM users WHERE id = ?",
      [session[:user_id]]
    ).first
  end

  def logged_in?
    !!current_user
  end

  def require_login
    redirect('/login') unless logged_in?
  end

  def owns_post?(post)
    post && current_user && post["user_id"] == current_user["id"]
  end
end

get('/') do
  @posts = @db.execute("SELECT * FROM posts")
  slim(:home)
end

post('/upload') do

  title = params[:title]
  description = params[:description]
  price = params[:price].to_f
  price_type = params[:price_type]

  if params[:image] && params[:image][:tempfile] && params[:image][:filename]
    tempfile = params[:image][:tempfile]

    filename = params[:image][:filename]
    filename = filename.force_encoding("UTF-8")
    filename = filename.gsub(/[^0-9A-Za-z.\-]/, "_")

    save_path = "./public/img/#{filename}"

    File.open(save_path, "wb") do |f|
      f.write(tempfile.read)
    end

    image_url = "/img/#{filename}"
  else
    image_url = nil
  end

  @db.execute(
    "INSERT INTO posts (title, description, price_type, price, image_url, user_id)
     VALUES (?, ?, ?, ?, ?, ?)",
    [title, description, price_type, price, image_url, current_user["id"]]
  )

  redirect('/')
end

post("/:id/return") do
    redirect('/')
end

get('/:id/post') do
  id = params[:id].to_i

  @posts = @db.execute(
    "SELECT posts.*, users.username 
    FROM posts 
    LEFT JOIN users ON posts.user_id = users.id 
    WHERE posts.id = ?",
    [id]).first
  slim(:post)
end

get('/register') do
  slim(:register)
end

post('/register') do
  username = params[:username]
  password = params[:password]

  password_digest = BCrypt::Password.create(password)
  password_confirm = params[:password_confirm]

  if password != password_confirm
    @error = "Lösenorden matchar inte"
    return slim(:register)
  end

  if username.strip.empty? || password.strip.empty?
    @error = "Vänligen fyll i alla fält"
    return slim(:register)
  end

  existing_user = @db.execute("SELECT * FROM users WHERE username = ?", [username]).first
  if existing_user
    @error = "Användarnamnet är redan taget"
    return slim(:register)
  end

  @db.execute(
    "INSERT INTO users (username, password_digest) VALUES (?, ?)",
    [username, password_digest]
  )

  redirect('/login')
end

get('/login') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]

  user = @db.execute("SELECT * FROM users WHERE username = ?", [username]).first

  if user && BCrypt::Password.new(user["password_digest"]) == password
    session[:user_id] = user["id"]
    redirect('/')
  else
    session[:error] = "Något gick fel"
    redirect('/login')
  end
end

get('/logout') do
  session.clear
  redirect('/')
end

post('/:id/update') do

  id = params[:id].to_i
  post = @db.execute("SELECT * FROM posts WHERE id = ?", [id]).first

  if owns_post?(post)
    title = params[:title]
    description = params[:description]
    price = params[:price].to_f
    price_type = params[:price_type]

    if params[:image] && params[:image][:tempfile] && params[:image][:filename]
      tempfile = params[:image][:tempfile]

      filename = params[:image][:filename]
      filename = filename.force_encoding("UTF-8")
      filename = filename.gsub(/[^0-9A-Za-z.\-]/, "_")

      save_path = "./public/img/#{filename}"

      File.open(save_path, "wb") do |f|
        f.write(tempfile.read)
      end

      image_url = "/img/#{filename}"
    else
      image_url = post["image_url"]
    end

    @db.execute(
      "UPDATE posts SET title = ?, description = ?, price_type = ?, price = ?, image_url = ? WHERE id = ?",
      [title, description, price_type, price, image_url, id]
    )
  end

  redirect('/myads')
end

get('/:id/update') do

  id = params[:id].to_i
  @posts = @db.execute("SELECT * FROM posts WHERE id = ?", [id]).first

  if owns_post?(@posts)
    slim(:update)
  else
    redirect('/myads')
  end
end

get('/upload') do
  slim(:upload)
end