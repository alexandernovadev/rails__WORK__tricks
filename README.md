# rails_tricks
funciones de rails efective to work

Exportar crear excel
Vue con rails
upload images
sql optimized
# rails__WORK__tricks




# rake db:create   
=> Crear una base de datos con el name la app

# rails g controller namecontroller name_ruta
=> Genera una controlador con una ruta por default llamando name_ruta
    OJO name_ruta es opciones

# En rails SE TIENEN QUE CREAR LOS MODELOS DE PLURAL
# Esto es crear la tabla
rails g model Article title:string body:text visits_count:integer 

=> Entonces rail crea una tabla llamada articles
    en la base de datos

# rake db:migrate 
=> Observa los cambios que se hicieron, CREA TABLAS


# rake db:rollback
=> Esto devuelve la base de datos a una migracion anterior

# rake db:up
=> Opss metntira no haga nada

# Crear un article con
Article.create(title:"Segundo  articulo", body:"lorem impsun dolor memente moro",visits_count:3)

#Buscar articulo
Article.find(aui id)

## Borrar el ultimo articulo
Article.last.destroy

## Buscar por --.. find By solo retorna UNO
Article.find_by(title: "Aqui text")

## Buscar y retornar varios items
Article.where("title LIKE ?", "%articulo%")
Article.where.not("title LIKE ?", "%articulo%")
Article.where("title LIKE ? and body LIKE ?", "%articulo%", "%ahol%")

# Cuado instalamos devise hay que hacer install
rails g devise:install
# GENERAR EL FUCK MODEL
rails generate devise MODEL


# Editar una tabla y ponerle user references
rails generate migration add_user_id_to_articles user:references
rails generate migration add_state_to_behaviors state:integer
EN LA MIGRACION
    add_column :behaviors, :state, :integer, :default => 1

## Scaffold GENERA TODO EL CRUD VUISTA Y RUTAS
rails generate scaffold Comment user:references article:references body:text


# <p class="notice"><%= notice %></p>
# <p class="alert"><%= alert %></p>

<%# Vistas de RoR %>

<% Esto imprime cosas que hara una funcion %>

<%= con un igual imprime tambien el OBEJETO Esto imprime cosas %>


<%# Redirecciones %>
<%= link_to "Inicio", root_path %>

Esto es algo asi
<a href="aqui el path">Inicio</a>
<%# Redirecciones %>

# cuando tipeo
resources :articles,  

# Todos esas rutas se genera solo con resources
get "/articles"   => index
post "/articles"  => create
delete "/articles" => delete o detroy 
get "/articles/:id" => show
get "/articles/new" => new
get "/articles/:id/edit" => edit
patch "/articles/:id" => update
put "/articles/:id" => update

resources :articles,  exept:[:delete] #EXEPTO ESTAS
resources :articles,  only:[:create] #SOLO PARA

OJOOOOO hay que crear un controlador que se llame articles_controller


REINICIAR APP
bundle exec passenger-config restart-app

MIGRAR
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:migrate:status


Entrar a AWS
sudo ssh -i /home/alex/Documentos/work/production-terminal-aws.pem.txt ubuntu@18.191.99.229 
