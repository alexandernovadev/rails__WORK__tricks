  def sql_to_json(sql)
    json = []
    sql_string = sql.to_s
    data = ActiveRecord::Base.connection.execute(sql_string)
    data.map {|a| json <<  {"id" => a[0], "name" => a[1].to_s.capitalize} } 
    json
  end

  def removebarras(value)
    fix = value.to_s
    fix.gsub! "[", ""
    fix.gsub! "]", ""
    fix.gsub! "\"", ""
    fix
  end
  
  def getdatafilters

    area= removebarras(params[:area])
    cargo= removebarras(params[:cargo])
    localization= removebarras(params[:localization])
    user= removebarras(params[:user])
    company= removebarras(params[:company])
    group= removebarras(params[:group])   
    evaluation = removebarras(params[:evaluation])   
    grade = removebarras(params[:grade])   
    dateenroll = removebarras(params[:dateenroll])   
    questiontype = removebarras(params[:questiontype])   
    typeresponses = removebarras(params[:typeresponses])   
    level = removebarras(params[:level])   
     

    ## Do querys
    query_area = area.size == 0 ? "" : "and  u.area_id IN (#{area})"
    query_cargo = cargo.size == 0 ? "" : "and  u.position_id IN (#{cargo})"
    query_localization = localization.size == 0 ? "" : "and  u.localization_id IN (#{localization})"
    query_user = user.size == 0 ? "" : "and  u.id IN (#{user})"
    query_company = company.size == 0 ? "" : "and  u.company_id IN (#{company})"
    query_group = group.size == 0 ? "" : "and  u.group_id IN (#{group})"
    query_evaluation = evaluation.size == 0 ? "" : "and te.tevaluation_id IN (#{evaluation})"
    query_grade = grade.size == 0 ? "" : "and te.grade IN (#{grade})"
    query_nota = grade.size == 0 ? "" : "and te.grade BETWEEN #{params[:grade][0]} and #{params[:grade][1]}"
    query_questiontype = questiontype.size == 0 ? "" : "and q.question_type_id IN (#{questiontype})"
    query_typeresponses = typeresponses.size == 0 ? "" : "and a.correcta IN (#{typeresponses})"
    query_level = level.size == 0 ? "" : "and l.id IN (#{level})"


 
    if dateenroll.size != 0 
      if params[:dateenroll][0].size == 0
        sqlenroll = "and te.enroll <= '#{params[:dateenroll][1]}'"
      elsif params[:dateenroll][1].size == 0
        sqlenroll = "and te.enroll >= '#{params[:dateenroll][0]}'"
      else
        sqlenroll ="and te.enroll BETWEEN '#{params[:dateenroll][0]}' and '#{params[:dateenroll][1]}'"
      end 
    end
    query_dateenroll = dateenroll.size == 0 ? "" : sqlenroll

    # Vista Join 
    tenroll_sql_view = "create or replace view tenrrollsananotas as (
      select 
      te.tevaluation_id, 
      te.user_id, 
      te.enroll,
      te.grade,
      teva.nombre,
      q.question_type_id,
      a.id
      from tenrollments te
      inner join tevaluations teva on teva.id = te.tevaluation_id
      inner join tcategories tca on tca.tevaluation_id = te.tevaluation_id
      inner join questions q on q.tcategory_id = tca.id
      inner join answers a on a.question_id = q.id
      inner join users u on u.id = te.user_id
      inner join thistoric_evaluations the on the.tenrollment_id = te.id
      where true #{query_evaluation} #{query_nota} #{query_dateenroll} #{query_questiontype} #{query_typeresponses})"
      view2 = ActiveRecord::Base.connection.execute(tenroll_sql_view)

    #Vista principal
    user_sql_view = "create or replace view userstevaluations as (
    select 
      u.id, 
      LOWER(concat( u.name,' ',  u.second_name)) 'full_name',
      u.position_id,
      u.company_id,
      u.area_id,
      u.group_id,
      u.localization_id,
      te.tevaluation_id,
      te.question_type_id
    from users u 
    inner join tenrrollsananotas te on te.user_id = u.id
    inner join positions p ON u.position_id = p.id
    inner join levels l ON l.id = p.level_id
    where true #{query_area} #{query_cargo} #{query_localization} #{query_user} #{query_company} #{query_group} #{query_level})"
    view1 = ActiveRecord::Base.connection.execute(user_sql_view)

    levelin_cargo = "select distinct level_id from positions where id IN (select distinct position_id from userstevaluations)"
    json_filters = {
      :user => sql_to_json("select id, full_name from userstevaluations"),
      :cargo => sql_to_json("select id, name from positions where id IN (select distinct position_id from userstevaluations)"),
      :localization => sql_to_json("select id, name from localizations where id IN (select distinct localization_id from userstevaluations)"),
      :area => sql_to_json("select id, name from areas where id IN (select distinct area_id from userstevaluations)"),
      :company => sql_to_json("select id, name from companies where id IN (select distinct company_id from userstevaluations)"),
      :group => sql_to_json("select id, name from groups where id IN (select distinct group_id from userstevaluations)"),
      :level_position => sql_to_json("select id, name from levels where id IN (#{levelin_cargo})"),
      :question_types => sql_to_json("select id, name from question_types where id IN (select distinct question_type_id from userstevaluations)"),
      :evaluation => sql_to_json("select id, nombre from tevaluations where id IN (select distinct tevaluation_id from userstevaluations)")
    }
    
    respond_to do |format|
      format.json { render :json => json_filters}
    end
  end

  def getdatasabana
    area= removebarras(params[:area])
    cargo= removebarras(params[:cargo])
    localization= removebarras(params[:localization])
    user= removebarras(params[:user])
    company= removebarras(params[:company])
    group= removebarras(params[:group])   
    evaluation = removebarras(params[:evaluation])   
    grade = removebarras(params[:grade])   
    dateenroll = removebarras(params[:dateenroll])   
    questiontype = removebarras(params[:questiontype])   
    typeresponses = removebarras(params[:typeresponses])   

    ## Do querys

    query_area = area.size == 0 ? "" : "and  a.id IN (#{area})"
    query_cargo = cargo.size == 0 ? "" : "and  p.id IN (#{cargo})"
    query_localization = localization.size == 0 ? "" : "and  l.id IN (#{localization})"
    query_user = user.size == 0 ? "" : "and  u.id IN (#{user})"
    query_company = company.size == 0 ? "" : "and  c.id IN (#{company})"
    query_group = group.size == 0 ? "" : "and  g.id IN (#{group})"
    query_evaluation = evaluation.size == 0 ? "" : "and ten.tevaluation_id IN (#{evaluation})"
    query_grade = grade.size == 0 ? "" : "and te.grade IN (#{grade})"
    query_nota = grade.size == 0 ? "" : "and ten.grade BETWEEN #{params[:grade][0]} and #{params[:grade][1]}"
    query_questiontype = questiontype.size == 0 ? "" : "and q.question_type_id IN (#{questiontype})"
    query_typeresponses = typeresponses.size == 0 ? "" : "and a.correcta IN (#{typeresponses})"

    query_level_cargo = ""

    if dateenroll.size != 0 
      if params[:dateenroll][0].size == 0
        sqlenroll = "and ten.enroll <= '#{params[:dateenroll][1]}'"
      elsif params[:dateenroll][1].size == 0
        sqlenroll = "and ten.enroll >= '#{params[:dateenroll][0]}'"
      else
        sqlenroll ="and ten.enroll BETWEEN '#{params[:dateenroll][0]}' and '#{params[:dateenroll][1]}'"
      end 
    end
    query_dateenroll = dateenroll.size == 0 ? "" : sqlenroll


    #query_level_cargo = removebarras(level_cargo).empty? ? "" : "and p.level_id IN (#{removebarras(level_cargo)})"



    ## DO SQL consult 
    view1 = "create or replace view question_with_answers as(
      select
        a.id as 'id_answer',
        REPLACE(REPLACE(a.respuesta , CHAR(13), ' '), CHAR(10), ' ') 'name_answer',
        q.id 'id_question',
        REPLACE(REPLACE(q.enunciado, CHAR(13), ' '), CHAR(10), ' ') 'name_question',
        if(a.correcta = 0, 'Incorrecta','Correcta') as 'status'
      from answers a 
      inner join questions q on q.id = a.question_id
      where true #{query_questiontype} #{query_typeresponses})"
      v1 = ActiveRecord::Base.connection.execute(view1)

    view2 = "create or replace view users_data_sabana as (
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
      where u.profile_id != 1 #{query_company} #{query_cargo} #{query_level_cargo}
      #{query_area} #{query_localization} #{query_group} #{query_user}
    )"
    v2 = ActiveRecord::Base.connection.execute(view2)

    # TODO ya se como hacer los titulos personalizador con un concat
    view3 = "
    create or replace view report_sabana_notas as (
      select 
        u.identity 'Identificacion',
        u.full_name 'Nombre usuario',
        u.company 'Compañia',
        u.cargo 'Cargo',
        u.area 'Area',
        u.localization 'Localizacion',
        u.group 'Grupo',
        te.nombre as 'Nombre Evaluacion',
        REPLACE(prta.name_question,',',';') 'Nombre pregunta',
        REPLACE(prta.name_answer,',',';' ) 'Respuestas',
        prta.status 'status',
        if(tha.user_answer = 0, '--','SELECCIONADA') 'Respuesta usuario'
      from thistoric_evaluations the
      inner join users_data_sabana u ON u.id_uuser = the.user_id 
      inner join tenrollments ten ON ten.id = the.tenrollment_id
      inner join thistoric_questions thq ON thq.thistoric_evaluation_id = the.id
      inner join tevaluations te ON te.id = ten.tevaluation_id
      inner join question_with_answers prta ON prta.id_question = thq.question_id
      inner join thistoric_answers tha ON tha.thistoric_question_id = thq.id 
      where true #{query_evaluation} #{query_nota} #{query_dateenroll})"
      v3 = ActiveRecord::Base.connection.execute(view3)
    
      
      if params[:size]
        data = ActiveRecord::Base.connection.execute("select count(*) from report_sabana_notas;")
        respond_to do |format|
          format.json { render :json => {:count => data, :haysi => "SOLO SIZE"}}
        end
      elsif params[:excel]
        data_sql = ActiveRecord::Base.connection.execute("select * from report_sabana_notas;")
        columns_sql = ActiveRecord::Base.connection.execute("show columns from report_sabana_notas;")
     
        ## Do excel
        sheets = ['Reporte_evaluaciones']
        labelfieds = []
        
        columns_sql.map{|x| labelfieds << x[0] } 

        labels = [labelfieds]
        models = [data_sql]
        # Algoritmo bucleexcel by alexsk88
        report = Axlsx::Package.new
        wb = report.workbook
        sheets.each_with_index do |name_sheet,i_sheet|
          wb.add_worksheet(name: name_sheet.to_s) do |view|
            title = wb.styles.add_style(:bg_color => "d1d0d0", :fg_color=>"000000", 
            :sz=>12, :b=>true,  :border=> {:style => :thin, :color => "d1d0d0"}, :alignment=>{:horizontal => :center})

            wrapinif = wb.styles.add_style(:alignment => {:wrap_text => true})
            view.add_row labels[i_sheet], :style => title
            models[i_sheet].each do |value_model|
                row_data = []
                labels[i_sheet].size.times do |ind|
                    row_data.push value_model[ind.to_i].nil? ? 'NULL' : value_model[ind.to_i].to_s
                end
                view.add_row row_data, :style => wrapinif
            end
          end   
        end

      
        FileUtils.rm_r Dir.glob("#{Rails.root.to_s}/public/xlsx")
      
        tm = Time.now.utc.to_i
        dir = "/public/xlsx/#{tm}"
        if not File.exists?(Rails.root.to_s + dir)
          FileUtils.mkdir_p(Rails.root.to_s + dir)
        end
        File.open(Rails.root.join('public', 'xlsx',tm.to_s,'reporte_excel.xlsx'), 'wb') do |file|
          file.write(report.to_stream.read)
        end

        respond_to do |format|
          format.json { render :json => {:url => "xlsx/#{tm}/reporte_excel.xlsx" }}
        end

      elsif params[:onlydata]
        ant = params[:ant]
        sig = params[:next]

        data = ActiveRecord::Base.connection.execute("select * from report_sabana_notas LIMIT #{ant},#{sig};")

        respond_to do |format|
          format.json { render :json => {:data => data,:msg => "Solo data [#{ant}--#{sig}] "}}
        end
      end

     
  end
