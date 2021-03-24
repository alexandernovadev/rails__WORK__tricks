
<%= form_tag '/ImportPlanillaCapacitacion/test_1', 
                :style => "display: inline;" do %>
                <%= submit_tag("&#xf1c3; RAPIDOOO".html_safe, :alt => "Exportar datos", 
                :title => "Exportar datos",:class => "btn-button button--green", 
                    :style => "font-family: FontAwesome, verdana, sans-serif; margin-top: 0; margin-right: 5px;") %>
            <% end %>

def test_1

    # Filtros 
    proyecto = 5
    area= 1
    position= 17

    # Falta logica para filtros
    
    vista = "create or replace view torails as (
        select 
            er.assignment_id as 'assignment_id',
            a.evaluator_id as 'evaluator_id',
            u.id as 'user_id',
            er.relation_id as 'relation_id',
            s.project_id as 'project_id',
            s.id as 'survey_id',
            er.family_competence_id as 'family_competence_id',
            er.competence_id as 'competence_id',
            er.behavior_id as 'behavior_id',
            er.score as 'score', 
            er.ideal as 'ideal'
        from evaluator_relations er
        join assignments a ON er.assignment_id = a.id and a.status = 3
        join surveys s ON a.survey_id = s.id and s.project_id = #{proyecto}
        inner join users u ON u.id = a.evaluated_id and u.status = 1 )"

        records_array = ActiveRecord::Base.connection.execute(vista)


        sql2 = "select 
        concat(u_ev.second_name,' ',u_ev.name) as 'nombre Evaluador',
        u_ev.identity,
        concat(u.second_name,' ',u.name) as 'nombre Evaluado',
        u.identity as 'identify eval',
        p.name as 'Cargo',
        l.name as 'Nivel',
        a.name as 'Area',
        g.name as 'Grupo',
        loc.name as 'Localizacion',
        com.name as 'Compañia',
        pro.name as 'Proyecto',
        s.name as 'Encuesta',
        re.name as 'Relacion',
        COALESCE(c.name, 'SIN COMPETENCIA' ) as 'Compencia',
        sq.statement as 'Pregunta',
        r1.score,
        r1.ideal,
        ((r1.score*100)/r1.ideal) as '%'
        from report_1 r1
        left join users u ON u.id = r1.user_id
        left join users u_ev ON u_ev.id = r1.evaluator_id
        left join relations re ON re.id = r1.relation_id
        left join competences c ON c.id = r1.competence_id
        left join surveys s ON s.id = r1.survey_id
        left join positions p ON p.id = u.position_id
        left join survey_questions sq ON sq.id = r1.behavior_id
        left join levels l ON l.id = p.level_id
        left join areas a ON a.id = u.area_id
        left join groups g ON g.id = u.group_id
        left join localizations loc ON loc.id = u.localization_id
        left join companies com ON com.id = u.company_id
        left join projects pro ON pro.id = s.project_id
        order by r1.evaluator_id,r1.user_id, r1.family_competence_id"

        sql3 = "select  * from torails"
        sera = ActiveRecord::Base.connection.execute(sql2)
        p "SERA ES REAL #{sera.size}"

        p = Axlsx::Package.new
        wb = p.workbook
        wb.add_worksheet(name: "Resultados de Competencias") do |sheet|
          title = wb.styles.add_style(:bg_color => "d1d0d0", :fg_color=>"000000", 
            :sz=>12, :b=>true,  :border=> {:style => :thin, :color => "d1d0d0"}, :alignment=>{:horizontal => :center})
          sheet.add_row [
            "Evaluador",
            "Identificación",
            "Evaluado",
            "Identificación",
            "Cargo",
            "Nivel Cargo",
            "Área",
            "Grupo",
            "Localización",
            "Compañía",
            "Proyecto",
            "Encuesta",
            "Relación",
            "Competencia",
            "Pregunta",
            "Resultado",
            "Ideal",
            "% Cumplimiento"
          ], :style => title

        sera.each_with_index do |x,idx|
            row_data = []
            
            row_data.push x[0]
            row_data.push x[1]
            row_data.push x[2]
            row_data.push x[3]
            row_data.push x[4]
            row_data.push x[5]
            row_data.push x[6]
            row_data.push x[7]
            row_data.push x[8]
            row_data.push x[9]
            row_data.push x[10]
            row_data.push x[11]
            row_data.push x[12]
            row_data.push x[13]
            row_data.push x[14]
            row_data.push x[15]
            row_data.push x[16]
            row_data.push x[17]

        sheet.add_row row_data
        end
    end

    name_report = Time.zone.now.strftime('%m/%d/%y')+"_Reporte_Objetivos.xlsx"
    send_data p.to_stream.read, type: "application/xlsx", filename: name_report
        
    end
