class ImportPlanillaCapacitacionController < ApplicationController

    def import_plantilla_capacitacion

        workbook = Spreadsheet.open(params[:xlsx_file].path)
        sheet1 = workbook.worksheet(0) # can use an index or worksheet name

        if workbook.worksheet('eCertKey')
            data = []
            errors = []

        sheet1.each_with_index do |row, index|
            # Si esta vacia la hoja ERROR
            break if row[0].nil? 

            # No lea los titulos 
            next if index == 0

            hash = {}
            hasherrors = {}

            hash.merge!({'Cedula'=> row[0].to_i.to_s})
            hash.merge!({'id_curso'=> row[1].to_i})
            hash.merge!({'id_programacion_curso'=> row[2].to_i})
            hash.merge!({'fecha_inicio'=> row[3]})
            hash.merge!({'fecha_final'=> row[4]})
            hash.merge!({'progreso'=> row[5]})
            hash.merge!({'nota'=> row[6]})

            data << hash

            ## CAMPOS VACIOS
            if  row[0].blank?
                hasherrors.merge!({"Cedula: "=> "(Fila No. #{index}) Cedula No puede estar vacio "})
            end
            if  row[1].blank?
                hasherrors.merge!({"Id_Curso: "=> "(Fila No. #{index}) ID Curso No puede estar vacio "})
            end
            if  row[2].blank?
                hasherrors.merge!({"Id Programación: "=> "(Fila No. #{index}) ID Programacion No puede estar vacio "})
            end
            if  row[3].blank?
                hasherrors.merge!({"Fecha Inicio: "=> " (Fila No. #{index}) Fecha Inicio No puede estar vacio"})
            end
            if  row[4].blank?
                hasherrors.merge!({"Fecha FInal: "=> "(Fila No. #{index}) Fecha Final No puede estar vacio "})
            end
            if  row[5].blank?
                hasherrors.merge!({"Progreso: "=> "(Fila No. #{index}) Progreso No puede estar vacio "})
            end
            if  row[6].blank?
                hasherrors.merge!({"Nota: "=> "(Fila No. #{index}) Progreso No puede estar vacio "})
            end
            ## CAMPOS VACIOS

            ## ValidarCedula
            User.where(:identity => row[0].to_i.to_s).exists? ? '' : 
            if row[0].to_s.to_i.blank? || row[0].to_s.to_i.nil? || row[0].to_s.to_i == '0'
                hasherrors.merge!({"Cedula: "=> "No debe estar Vacia"})
            else
                hasherrors.merge!({"Cedula: "=> "(Fila No. #{index}) La Cedula '#{row[0].to_s.to_i}' No existe en la lista de usuarios"})
            end

            ## Validar Id curso
            Course.where(:id => row[1].to_i).exists? ? '' : 
            hasherrors.merge!({"Curso: "=> "(Fila No. #{index}) El curso con el ID '#{row[1].to_i}' No existe en la lista de cursos"})

            ## Validar Id programacion curso
            CourseSchedule.where(:id => row[2].to_i).exists? ? '' : 
            hasherrors.merge!({"Id programacion: "=> "(Fila No. #{index}) El id de Programacion '#{row[2].to_i}' No existe en la lista de programaciones"})

            ## Validar Fecha de Inicio
            # Este regex valida año desde 1900 - 2999
            # mes de 01-12
            # dia de 01-31
            # test here: https://regexr.com/3e48o
            regex = /^(19[0-9][0-9]|20[0-9][0-9])-([0][1-9]|[1][0-2])-([0][1-9]|[1][0-9]|[2][0-9]|[3][0-1])/

            if !row[3].blank? && row[3].to_s =~ regex
            puts 'matched', "\n"
            else
            hasherrors.merge!({"Fecha Inicio: "=> "(Fila No. #{index}) La Fecha de Inicio '#{row[3].to_s}' no tiene un formato valido "})
            end

            if !row[4].blank? && row[4].to_s =~ regex
            puts 'matched', "\n"
            else
            hasherrors.merge!({"Fecha Final: "=> "(Fila No. #{index}) La Fecha final '#{row[4].to_s}' no tiene un formato valido "})
            end

            ## Validar la Progresp
            if row[5].to_i >100 || row[5].to_i < 0 
                hasherrors.merge!({"Progreso: "=> "(Fila No. #{index}) El Progreso '#{row[5].to_s}' debe esta entre 0 y 100"})
            end

            ## Validar el Nota
            if Course.where(:id => row[1]).first
                maxgrade = Course.where(:id => row[1]).first.maxgrade
                if row[6].to_i > maxgrade 
                    hasherrors.merge!({"Nota: "=> "(Fila No. #{index}) 'La nota '#{row[6].to_s}' debe esta entre 0 y #{maxgrade}"})
                end
                if row[6].to_i < 0 
                    hasherrors.merge!({"Nota: "=> "(Fila No. #{index}) 'La nota '#{row[6].to_s}' debe esta entre 0 y #{maxgrade}"})
                end
            else
                hasherrors.merge!({"Nota: "=> "(Fila No. #{index}) #{row[6].to_s} NO EXISTE ID CUrso "})
            end
            
            # Validar Relaciones
            if User.where(:identity => row[0].to_i.to_s).exists?
                user = User.where(:identity => row[0].to_i.to_s).first
                
               unless Enrollment.where(:user_id => user.id,
                :course_schedule_id=>row[2], :course_id => row[1]).exists?
                hasherrors.merge!({"RELACION: "=> "(Fila No. #{index}) El usuario #{user.identity} no esta matricula al curso con el #{row[1]} "})

               end 
            end
            # Si no hay errores no agrege nada al array de errors y
            if hasherrors.size != 0
                errors << hasherrors
            end
        end

        @datason = data

        # Si hay errores notifiquelos a la vista
        if errors.size != 0
            @errorson = errors
        else
            # Subir Cambios
            data.each do |w|
                user = User.where(:identity => w['Cedula'].to_i.to_s).first

                enroll = Enrollment.where(:user_id => user.id,
                :course_schedule_id=>w['id_programacion_curso'], :course_id => w['id_curso']).first

                #@quees =  "#{@quees} #{user.id} #{enroll.grade}-- #{enroll.percentage} +++++++++" 
                enroll.grade = w['nota']
                enroll.percentage = w['progreso']
                
                enroll.save  
                
            end
            # Notifier.send_state_import_capacitation(current_user.email,"data").deliver
            # @quees = "HO> #{current_user.email}"
        end
        else
            @plantillavalida = "La plantilla no es VALIDA"
        end

    
        render template: "/import_planilla_capacitacion/index"
       
   end

    def send_plantilla_demo_capacitacion
        make()
    end

    def make
        sheets = ['asisitencia','Lista Cursos Programaciones','eCertKey']
        style = {:color=>:black, :weight=>:bold, :size=>10 }
        labels = 
        {
            0=> ["Cedula del Colaborador","id curso","id programacion de curso",
            "Fecha Inicio (año-mes-dia)","Fecha Final (año-mes-dia)",
            "Progreso","Nota"],

            1=> ["ID_curso","Nombre del Curso","Id programacion de curso",
                "Fecha Inicio (año-mes-dia)","Fecha Final (año-mes-dia)"],

            2=>["KEYID"]
        }
       

        # La data depende en que hoja vamos a insertarla
        ##  Por ejemplo en la 1 (Lista Cursos Programaciones)
        ##  La pasamos la data, recomendaria darle la data ya 
        ## Ya procesada para no tirarse el metodo
        models = {
            0 => [],
            1 => CourseSchedule.all,
            2 => ["123$%$s.22"]
        }

        
        book = create_excel(labels, style, sheets,models) 

    end

    def create_excel(labels, style, sheets, models)
        @labels = labels
        @style = style
        @sheets = sheets
        @models = models

        #Create Libro
        book = Spreadsheet::Workbook.new

        # Bucle de Hojas
        @sheets.each_with_index do |unidad, index|
            sheet = nil
            sheet = book.create_worksheet
            sheet.name = unidad

            # Negrilla a los titlos
            format = Spreadsheet::Format.new style
            sheet.row(0).default_format = format

            # Colocar Titles
            ## Bucle de Labels
            @labels.each do |k,v|
                if k == index
                    v.each_with_index do |label, i|
                        sheet.row(0).push label
                        sheet.column(i.to_i).width = label.size + 2
                    end
                end
            end
            
            # Set Data
            @models.each do |k,v|
                # TODO k = Listado de cursos / Deberia ser automatico ??
                if k == index
                    if k == 1
                        v.each_with_index do |course, idx| 
                            sheet.row(idx + 1).push course.course_id,course.course.name,
                                                    course.id, course.starts.strftime("%Y-%m-%d"), 
                                                    course.ends.strftime("%Y-%m-%d")
                        end
                    end

                    if k == 2
                        v.each_with_index do |c, idx| 
                            sheet.row(idx + 1).push c
                        end
                    end
    
                end
            end

        end
  
        #Formatear y enviar hoja
        spreadsheet = StringIO.new
        book.write spreadsheet

        # TODO EL NOMBRE DEL ARCHIOV too mejorar
        if true
            name_report = "Planilla Capacitacion Cursos.xls"
            send_data spreadsheet.string, :filename=> name_report, 
            :type=> "application/vnd.ms-excel; charset=UTF-8;"
        else
            render template: "/import_planilla_capacitacion/index"
        end
     
  
    end

    # TODO edicion ?
    def edit_excel
    end

    def read_excel
    end
end

