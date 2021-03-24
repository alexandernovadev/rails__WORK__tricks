  def get_test




    viw= "create or replace view users_data_test as (
    select
      u.id 'id_uuser',
      u.identity 'identity',
      concat(u.name, ' ', u.second_name) 'full_name',
      c.name 'company',
      p.name 'cargo',
      a.name 'area',
      l.name 'localization',
      g.name 'group'
    from users u
    inner join companies c ON c.id = u.company_id 
    inner join positions p ON p.id = u.position_id
    inner join areas a ON a.id = u.area_id
    inner join localizations l ON l.id = u.localization_id
    inner join groups g ON g.id = u.group_id
    where u.profile_id != 1
    limit 500)"

    crate_view3 = ActiveRecord::Base.connection.execute(viw)

    consulta_final = ActiveRecord::Base.connection.execute("select * from users_data_test")

    user = User.limit(5)
    data_json  = []
    shop  = []

    user.each do |a|
      data_json <<  {"id" => a.id, "name" => a.name, "born" => a.born}
    end
    consulta_final.each do |a|
      shop <<  {"id" => a[0], "cedula" => a[1], "full_name" => a[2]}
    end
    
    respond_to do |format|
      format.json { render :json => {:users =>data_json,:si=>consulta_final ,:pa=> params[:tenrollment_id], :lo=>shop}}
    end
  end
  
  
  
  
  
  
  
  ##############################
  
  
  <script  src = "https://cdn.jsdelivr.net/npm/vue"></script>

<%= link_to image_tag("back.png", :title => 'Volver a Unidades de medida'),ereports_path %>
<style>
    body{
        font-size: 13px;
    }
</style>
<div id="app">
    {{ message }}
   
   <div v-if="ab != null">
    <div v-for="(item, i) in ab" :key="i">

        {{item.id}}
        {{item.born}}
        {{item.name}}
<hr/>
    </div>
   </div>

<button class="btn btn-danger" @click="ge('key')"> HABERT</button>
</div>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script>


var app = new Vue({
    el: '#app',
    data: {
        message: 'Hello Vue!',
        mi: [],
        ab: null
    },
    methods: {
        transformData(obj){
            return JSON.parse(obj.replace(/&quot;/g,'"'))
            
        },
        ge(w){
            
            this.www()
            console.log(this.ab);

            

        },
        www(){
            var self = this 
            this.ab = 'sss'
            url_host = "/treports/get_test";
            a = {tenrollment_id: "soed", tiempo: 'time_actual'}
                $.post(url_host,a)
                .success(function( result,state ) {
                    
                    self.ab = result.users
                    console.log(result);

            
                })
                .fail(function() {
                console.log( "error al guardar el tiempo" );
                alert('Error del servidor (save time), tome un pantallazo y envielo al equipo de sorporte')
                })

        }
    },
    mounted() {
        // this.mi = this.transformData("<%=@dato.to_json%>")
    },
})

</script>
