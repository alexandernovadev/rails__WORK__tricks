   def make_optimized()

        ###########################################################################
        ######## Si el numero de sheet no coincide con el modelo hay errores ######
        ###########################################################################
        
        # Capturando los titulos de la table# TODO optimizar nombres para que coincidan con n numeros de datos
        titles_evaluations = Evaluation.column_names
        titles_evaluations_user = EvaluationUser.column_names
        titles_evaluation_categories = EvaluationCategory.column_names
        titles_objetives = Objective.column_names
        titles_categories = Category.column_names
        titles_periods = Period.column_names
        titles_indicators = Indicator.column_names
        titles_objectives_types = ObjectiveType.column_names
        titles_standard_objectives = StandardObjective.column_names
        titles_calculations = Calculation.column_names
        titles_state_followups = StateFollowup.column_names


        # Haciendo Consultas SQL direct ## TODO optimizar nombres para que coincidan con n numeros de datos
        evaluations = ActiveRecord::Base.connection.execute("select * from evaluations;")
        evaluation_users = ActiveRecord::Base.connection.execute("select * from evaluation_users;")
        evaluation_categories = ActiveRecord::Base.connection.execute("select * from evaluation_categories;")
        categories = ActiveRecord::Base.connection.execute("select * from categories;")
        periods = ActiveRecord::Base.connection.execute("select * from periods;")
        indicators = ActiveRecord::Base.connection.execute("select * from indicators;")
        objectives_types = ActiveRecord::Base.connection.execute("select * from objective_types;")
        standard_objectives = ActiveRecord::Base.connection.execute("select * from standard_objectives;")
        calculations = ActiveRecord::Base.connection.execute("select * from calculations;")
        state_followups = ActiveRecord::Base.connection.execute("select * from state_followups;")
       
 
        ##########################################
        ## AQUI HAY PROBLEMAS CON EL UTF-8

        lopa = []

        titles_objetives.each do |x|
            lopa << "convert(binary convert(obj.#{x.to_s} using latin1) using utf8)"
        end

        fix = lopa.to_s
        fix.gsub! "]", ""
        fix.gsub! "\"", ""
        fix.gsub! "[", ""
        p " lola #{fix}"

        ppp= "select #{fix} from objectives obj;"
        # objetives = ActiveRecord::Base.connection.execute("select * from objectives;")
        objetives = ActiveRecord::Base.connection.execute(ppp)

        ## AQUI HAY PROBLEMAS CON EL UTF-8
        ##########################################



        # Creando arrays para buclear               
        sheets = ['Evaluations',
                    "Evaluations_user",
                    "Evaluation_Categorias",
                    "Objetivos",
                    "Tipo de Objetivos",
                    "Estandard_Objectives",
                    "Calculaciones",
                    "Estado Seguimiento",
                    "Categorias",
                    "Periodos",
                    "Indicadores"]

        labels = [titles_evaluations,
            titles_evaluations_user,
            titles_evaluation_categories,
            titles_objetives,
            titles_objectives_types,
            titles_standard_objectives,
            titles_calculations,
            titles_state_followups,
            titles_categories,
            titles_periods,
            titles_indicators]

        models = [evaluations,
            evaluation_users,
            evaluation_categories,
            objetives,
            objectives_types,
            standard_objectives,
            calculations,
            state_followups,
            categories,
            periods,
            indicators]


        # Creando un excel
        report = Axlsx::Package.new
        wb = report.workbook

        # Algoritmo buclexcel 
        sheets.each_with_index do |name_sheet,i_sheet|
        
            wb.add_worksheet(name: name_sheet.to_s) do |view|
                title = wb.styles.add_style(:bg_color => "d1d0d0", :fg_color=>"000000", 
                :sz=>12, :b=>true,  :border=> {:style => :thin, :color => "d1d0d0"}, :alignment=>{:horizontal => :center})
                view.add_row labels[i_sheet], :style => title

                models[i_sheet].each do |value_model|
                    row_data = []
                    labels[i_sheet].size.times do |ind|
                        row_data.push value_model[ind.to_i].nil? ? 'NULL' : value_model[ind.to_i].to_s
                    end
                    view.add_row row_data
                end

            end   
        end
        name_report = Time.zone.now.strftime('%m/%d/%y')+"_historico_objetivos.xlsx"
        send_data report.to_stream.read, type: "application/xlsx", filename: name_report   
    end



  <%= form_tag '/dev_plans/make_optimized', 
                :style => "display: inline;" do %>
                <%= submit_tag("&#xf1c3; APP".html_safe, :alt => "Exportar datos", 
                :title => "Exportar datos",:class => "btn-button button--green", 
                    :style => "font-family: FontAwesome, verdana, sans-serif; margin-top: 0; margin-right: 5px;") %>
            <% end %>


# Parte 2 Bucleexcel mejorado con orden y enviando solo el link de descarga
 def bucleexcel_make(name)
        # La lista de hojas tiene que coincidor la el numero labels y Modelos !!!!!!!
        
        # Lista de Hojas
        sheets = ['Curso','Tipo Curso','Provedores', 'Clasificacion Cursos','Tutor']
        

        # Lista de labales
        lbs_curso = ['Nombre curso','Código','Link','Descripción','Objetivos','Dirijido a','Horas totales','Id Tipo curso','Id Proveedor','Id Clasificación',
        'Nota Minima','Nota Maxima','Agregar a Biblioteca','Id_Tutor','Certificado', 'Texto adicional al certificado','Imagen Player','Dias de visualización',
        'Tiene curso prerequisito','Id Curso Prerequisito','Keyword']
        lbs_tipocurso = [ 'ID','Tipo Curso']
        lbs_provedors = [ 'ID','Provedor']
        lbs_curosclasi = [ 'ID','Clasificación']
        lbs_tutor = [ 'ID','Nombre','Cedula']

        # Lista Modelos
        mdl_curso = [' ']
        mdl_tipocurso = CourseType.select("id, name")
        mdl_provedors = CourseProvider.select("id,name")
        mdl_curosclasi = CourseClasification.select("id,name")
        mdl_tutor = User.select("id, CONCAT(name,' ',second_name) 'nameuser', identity")

        ######################
        # Set data a buclexcel
        labels = [lbs_curso,lbs_tipocurso,lbs_provedors,lbs_curosclasi,lbs_tutor]
        models = [mdl_curso ,mdl_tipocurso ,mdl_provedors,mdl_curosclasi ,mdl_tutor]

        # Algoritmo bucleexcel 
        report = Axlsx::Package.new
        wb = report.workbook
        sheets.each_with_index do |name_sheet,i_sheet|
        
        wb.add_worksheet(name: name_sheet.to_s) do |view|
            # Estilo para los titles
            title = wb.styles.add_style(:bg_color => "d1d0d0", :fg_color=>"000000", 
            :sz=>10, :b=>true,  :border=> {:style => :thin, :color => "d1d0d0"}, :alignment=>{:horizontal => :center,:wrap_text => true})

            # Estilo para los campos normales
            wrapinif = wb.styles.add_style(:alignment => {:wrap_text => true,:horizontal => :left,:vertical => :top,},:sz=>10)
            view.add_row labels[i_sheet], :style => title
        
            models[i_sheet].each do |value_model|
            row_data = []

            case i_sheet
            when 0 # Cursos
                # row_data.push value_model
            when 1 # Curso Type
                row_data.push value_model.id
                row_data.push value_model.name
            when 2 # Curso Provedores
                row_data.push value_model.id
                row_data.push value_model.name
            when 3 # Cursos Clasifitions
                row_data.push value_model.id
                row_data.push value_model.name.titleize
            when 4 # Users to Tutor 
                row_data.push value_model.id
                row_data.push value_model.nameuser.titleize
                row_data.push value_model.identity
            else
                row_data.push ''
            end

            view.add_row row_data, :style => wrapinif # Add Style each fila
            view.column_widths 15,20,20# Size de cada clumna
            end

        end

        end
        # Lo guardo el la carpeta temporal y envio en link de descarga
        FileUtils.rm_r Dir.glob("#{Rails.root.to_s}/public/xls")
        tm = Time.now.utc.to_i # Name unico con unix date
        dir = "/public/xls/#{tm}"
        if not File.exists?(Rails.root.to_s + dir) #Remove Directory if exists
            FileUtils.mkdir_p(Rails.root.to_s + dir)
        end
        # Save File
        File.open(Rails.root.join('public', 'xls',tm.to_s,name+'.xls'), 'wb') do |file|
            file.write(report.to_stream.read)
        end

        # Envio el path del la hoja ecxel
        link ="xls/#{tm}/#{name}.xls"   
    end

################################3
# AHora con spreeadSheet GEM

 def bucleexcel_make(name)
        # La lista de hojas tiene que coincidor la el numero labels y Modelos !!!!!!!
        
        # Lista de Hojas
        sheets = ['Curso','Tipo Curso','Provedores', 'Clasificacion Cursos','Tutor']
        

        # Lista de labales
        lbs_curso = ['Nombre curso','Código','Link','Descripción','Objetivos','Dirijido a','Horas totales','Id Tipo curso','Id Proveedor','Id Clasificación',
        'Nota Minima','Nota Maxima','Agregar a Biblioteca','Id_Tutor','Certificado', 'Texto adicional al certificado','Imagen Player','Dias de visualización',
        'Tiene curso prerequisito','Id Curso Prerequisito','Keyword']
        lbs_tipocurso = [ 'ID','Tipo Curso']
        lbs_provedors = [ 'ID','Provedor']
        lbs_curosclasi = [ 'ID','Clasificación']
        lbs_tutor = [ 'ID','Nombre','Cedula']

        # Lista Modelos
        mdl_curso = [' ']
        mdl_tipocurso = CourseType.select("id, name")
        mdl_provedors = CourseProvider.select("id,name")
        mdl_curosclasi = CourseClasification.select("id,name")
        mdl_tutor = User.select("id, CONCAT(name,' ',second_name) 'nameuser', identity")

        ######################
        # Set data a buclexcel
        labels = [lbs_curso,lbs_tipocurso,lbs_provedors,lbs_curosclasi,lbs_tutor]
        models = [mdl_curso ,mdl_tipocurso ,mdl_provedors,mdl_curosclasi ,mdl_tutor]

        # Algoritmo bucleexcel con Spreadsheet
        report = Spreadsheet::Workbook.new

        sheets.each_with_index do |name_sheet,i_sheet|
            # Make Sheet y name
            sheet = report.create_worksheet
            sheet.name = name_sheet

            # Poner Los titulos
            ## Style titles   
            format = Spreadsheet::Format.new :color=>:black, :weight=>:bold, :size=>10
            sheet.row(0).default_format = format

            labels[i_sheet].each_with_index do |x, idxlbl| 
                sheet.row(0).push x
                # Para el campo link dejar ancho de 10
                sheet.column(idxlbl).width = x.size + (idxlbl == 2 ? 14 : 8)
            end

            # Set Data (Models)
            models[i_sheet].each_with_index do |value_model,idx|
                case i_sheet
                when 0 # Cursos
                    # row_data.push value_model
                when 1 # Curso Type
                    sheet.row(idx + 1).push value_model.id
                    sheet.row(idx + 1).push value_model.name
                when 2 # Curso Provedores
                    sheet.row(idx + 1).push value_model.id
                    sheet.row(idx + 1).push value_model.name
                when 3 # Cursos Clasifitions
                    sheet.row(idx + 1).push value_model.id
                    sheet.row(idx + 1).push value_model.name.titleize
                when 4 # Users to Tutor 
                    sheet.row(idx + 1).push value_model.id
                    sheet.row(idx + 1).push value_model.nameuser.titleize
                    sheet.row(idx + 1).push value_model.identity
                    sheet.column(idx + 1).width = value_model.nameuser.size + 8
                else
                    sheet.row(idx + 1).push ''
                end
            end
        end
        # Lo guardo el la carpeta temporal y envio en link de descarga
        FileUtils.rm_r Dir.glob("#{Rails.root.to_s}/public/xls")
        tm = Time.now.utc.to_i # Name unico con unix date
        dir = "/public/xls/#{tm}"
        if not File.exists?(Rails.root.to_s + dir) #Remove Directory if exists
            FileUtils.mkdir_p(Rails.root.to_s + dir)
        end

        #Formatear y enviar hoja
        spreadsheet = StringIO.new
        report.write spreadsheet

        # Save File
        File.open(Rails.root.join('public', 'xls',tm.to_s,name+'.xls'), 'wb') do |file|
            file.write(spreadsheet.string)
            # file.write(report.to_stream.read)
        end

        # Envio el path del la hoja ecxel
        link ="xls/#{tm}/#{name}.xls"   
    end

