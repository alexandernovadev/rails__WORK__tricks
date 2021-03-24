<%= form_tag('/volatility_questions/index') do %>
  <table class="clearboth">
    <tbody>
      <tr>
        <td>
          Estado<br>
          <%= select_tag "estado", options_for_select([['Inactivo', 0], ['Activo',1]], @actual_estate),include_blank: true %>
        </td> 
        
        <td>
        <%# Esto se puede llenar desde la base de datos 
        pero como solo el volatilidad y potencial, entonces lo hize asi
        para que no haga una peticion SQL en vano  %>
          Tipo<br>
          <%= select_tag "tipo", options_for_select([['Volatilidad', 1], ['Potencial',2]], @actual_tipo),include_blank: true %>
        </td>
    
      </tr>
      <tr>
        <td colspan="2">
          <%= submit_tag nil, :value => "&#xf002; Buscar".html_safe, :class => 'btn-button button--indigo' ,:style => "font-family: FontAwesome, verdana, sans-serif;" %>
          <%= link_to  '<i class="fa fa-paint-brush"></i>Limpiar'.html_safe, volatility_questions_path, class: "btn-button button--orange", style: "margin-left: 5px; margin-top: 1px;" %>
        </td>
      </tr>
    </tbody>
  </table>
<% end %>

