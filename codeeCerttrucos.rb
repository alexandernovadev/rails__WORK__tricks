
# CREAR UNA HOja de excel y enviarla
# _____________________________________
def report_courses_excel

    # Crear una hoja
    require 'spreadsheet'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.name = 'Cursos'
    # Titulos de la hoja
    sheet1.row(0).concat %w{Nombre Estado Código Clasificación\ del\ curso Tipo\ de\ curso Tutor Provedor Fecha\ Inicio Fecha\ Finalización Horas\ Totales Nota\ Minima Agregar\ a\ biblioteca 2\ o\ más\ evaluaciones? Evaluaciones }
    format = Spreadsheet::Format.new :color=>:black, :weight=>:bold, :size=>10
    centrar = Spreadsheet::Format.new :text_wrap => true
    sheet1.row(0).default_format = format

    # Dar ancho a las columnas
    for i in 0..14
      sheet1.column(i).width = 22
    end
    
    # Llenar la hoja
      ## Load data
    courses_active = Course.where("course_status_id = 1").order(:name)
    courses_inactive = Course.where("course_status_id = 2").order(:name)
    @courses = courses_active + courses_inactive

    ## Add Data
    @courses.each_with_index do |course, index| 
      
      sheet1.row(index + 1).push course.name, course.course_status.name, course.code,
      (course.course_clasification.nil? ? "---" : course.course_clasification.name),
      (course.course_type.name unless course.course_type.nil?),course.user.name,
      (course.course_provider.name if course.course_provider),course.starting,course.ending,
      course.total_hours, course.mingrade, (course.library_value.name unless course.library_value.nil?),
      ( (course.more_than_one_evaluation ? "Si " : "No ") + 
        ( tevaluations_course = TevaluationCourse.where("course_id = ?", course.id)
        tevaluations_course.size > 0 ? "( #{tevaluations_course.size} Evaluaciones Asociadas )" : "( 0 Evaluaciones Asociadas )")),
          ( getEvaluationCouruses(course.id) )
      
      #Ajustar texto
      sheet1.row(index + 1).default_format = centrar
    
    end
        
    #Formatear y enviar hoja
    spreadsheet = StringIO.new
    book.write spreadsheet
    name_report = "Reporte_Cursos_" + Time.now.strftime('%d-%m-%Y') + ".xls"
    send_data spreadsheet.string, :filename=> name_report, :type=> "application/vnd.ms-excel; charset=UTF-8;"
  end

  def getEvaluationCouruses(curse_id)
    evaluations = ""
    tevaluations_course = TevaluationCourse.where("course_id = ?", curse_id)
      if tevaluations_course.any? 
      tevaluations_course.each do |tevaluation_course| 
  
        evaluations.concat("* "+tevaluation_course.tevaluation.nombre + " \n")
      end 
    end
    "#{evaluations.present? ? "#{ evaluations}" : "Sin Evaluciones"}"
  end



<!-- Btn exportar todo los cursos a excel-->
<%= form_tag '/courses/report_courses_excel', :style => "display: inline;" do %>
  <%= submit_tag("&#xf1c3; Exportar Cursos".html_safe, :alt => "Exportar datos", :title => "Exportar datos",
  :class => "btn-button button--green", 
  :style => "font-family: FontAwesome, verdana, sans-serif; margin-top: 0; margin-right: 5px;") %>
<% end %>

# CREAR UNA HOja de excel y enviarla
# _____________________________________




# Crear y descargar una archivo binario
#______________________________________
def user_attendance_record_check_uploadcertificate
	
	
    enrollment = Enrollment.find(params[:eid])
    if enrollment.name_file_certificate.blank?

        ## Save File
        file_certicate = params[:xml_file]

        # Create Directory
        dir = "/public/uploads/certificado_course_shedule/#{enrollment.course_id.to_s}/#{enrollment.course_schedule_id.to_s}/#{enrollment.user_id.to_s}" 

        if not File.exists?(Rails.root.to_s + dir)
            FileUtils.mkdir_p(Rails.root.to_s + dir)
        end

        File.open(Rails.root.join('public', 'uploads','certificado_course_shedule',enrollment.course_id.to_s,
                                                                enrollment.course_schedule_id.to_s,enrollment.user_id.to_s,
                                                                file_certicate.original_filename), 'wb') do |file|
            file.write(file_certicate.read)
        end

        enrollment.name_file_certificate = "#{dir}/#{file_certicate.original_filename}"
    end

    enrollment.attendance_record = 1
    enrollment.percentage = 100
    
     url = "#{request.protocol}#{request.host_with_port}"

if enrollment.save
        #	Notifier.satisfaction_survey_notification(enrollment.user, enrollment, url).deliver
    end

    cs_id = enrollment.course_schedule_id
    c_id = {course_id: enrollment.course_id}
 redirect_to(course_schedules_attendance_record_user_path(:enrollment => c_id , :course_schedule_id => 	cs_id, :find => "Buscar" ))
end

def downloadfile
send_file params[:file_path].to_s
end


## VISTA

<td>
<% if enrollment.name_file_certificate.blank? %>
  <%= form_tag({controller: "course_schedules",
  action: "user_attendance_record_check_uploadcertificate"}, 
  multipart: true, remote: true) do %>
    <%= file_field_tag "xml_file" %>
    <%= text_field_tag "eid",  enrollment.id , class:"hide--element"%>
 
    <%= submit_tag("&#xf093; Cargar".html_safe,:class=>"btn-button button--deep-purple fvalida",
        :name=>"submit", style: "font-family: FontAwesome, verdana, sans-serif;") %>
        <br>
          <span class="msg-error text-danger">
   </span>
  <% end %>
<% else %>
 <a target="_blank" href="/course_schedules/download?file_path=<%=File.expand_path(".")+enrollment.name_file_certificate %>"
  class="btn-button button--teal" title="Descargar Archivo">
  <i class='fa fa-download' aria-hidden='true'></i>Descargar
</a>
  
<% end %>
</td>

# Crear y descargar una archivo binario
#______________________________________

