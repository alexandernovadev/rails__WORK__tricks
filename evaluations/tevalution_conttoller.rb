#encoding: utf-8

class TevaluationsController < ApplicationController

	layout :compute_layout

	def compute_layout
		#return "mainsinmenu" if action_name == "responder"
		return "main"  if action_name == "index"
		return "main"  if action_name == "new"
		return "main"  if action_name == "edit"
		return "main"  if action_name == "tevaluation_course"
		return "main"  if action_name == "asignacion_masiva"
		return "application"
	end

  def save_time
    ten = Tenrollment.find(params[:tenrollment_id].to_i)
    if ten
      #ten.timeleft = params[:tiempo]
      if dt = DateTime.parse(params[:tiempo].to_s) rescue false
          seconds = dt.hour * 3600 + dt.min * 60 + dt.sec
      end
      ten.timeleft = seconds #params[:tiempo]
      ten.save!
    end

    return
  end

  def resultados

    tenrollment =  Tenrollment.find(params[:tenrollment_id])
    
    tevaluation = tenrollment.tevaluation
    
    thistoric_evaluation = ThistoricEvaluation.where("tenrollment_id = ? AND attempt_id = ?",
                             params[:tenrollment_id],
                             params[:attempt_id]).first

    thistoric_question = ThistoricQuestion.where('thistoric_evaluation_id = ?',thistoric_evaluation.id).all

    array_rta_calification = []

    # nota maxima / numero de preguntas

    # Mirar si tiene un curso asignado
    tevaluation_courses = TevaluationCourse.by_tevaluation_id(tevaluation.id)

    if tevaluation_courses.any? 
      #puts "TIENE UN CURSO"      
      curso = Course.find(tevaluation_courses.first.course_id)
      nota_max = curso.maxgrade
      notamin = curso.mingrade
    else
      #puts "NOOOOO tiene curso"      
      nota_max = 100
      notamin = tevaluation.nota_min

    end

    notamax_entre_numberquetion = nota_max / thistoric_question.size  

    nota_final = 0

    thistoric_question.each do |tquestion|
      thistoric_answer = ThistoricAnswer.where("thistoric_question_id = ?", tquestion.id).all

      total_correctas = Answer.where("correcta = 1 AND id IN (?)",thistoric_answer.map{|x| x.answer_id}).size
      #puts "TOTAL RTA correctas #{tquestion.id } --> #{total_correctas}"
      # Para Seleccion Unica
      incorrectas_unica = 0
      correctas_unica = 0
      # Para Seleccion Multiple
      incorrectas_multiple = 0
      correctas_multiple = 0

      tipo_question = Question.find(tquestion.question_id).question_type_id   

      thistoric_answer.each do |answer|
        
        ((answer.user_answer.to_i == answer.correct_answer.to_i) && answer.correct_answer.to_i == 1) ? correctas_unica += 1 : incorrectas_unica += 1

        if answer.user_answer.to_i == 1
          ((answer.user_answer.to_i == answer.correct_answer.to_i) && answer.correct_answer.to_i == 1) ? correctas_multiple += 1 : incorrectas_multiple += 1
        end
  
      end

      if tipo_question == 1
        #puts "Unica rta"
        if correctas_unica > 0
          nota_final += notamax_entre_numberquetion
        else
          nota_final += 0
        end
        #puts "NOTA-> Final unica -> #{nota_final}"
      else 
        #puts "Multiple RTA"
        #(correctas_multiple - incorrectas_multiple) / total_correctas * nota_max/ numero_preguntas 
        nota_temporal = ((correctas_multiple.to_f - incorrectas_multiple.to_f) / total_correctas.to_f) * (notamax_entre_numberquetion.to_f)
        #p "****************"
        #p "FORMULA : (#{correctas_multiple} -#{incorrectas_multiple} ) / #{total_correctas} * (#{notamax_entre_numberquetion.to_f }) === #{nota_temporal.to_f}"
        #p "****************"
        nota_temporal > 0 ? nota_final+=nota_temporal :  nota_final += 0
      end

      # p "inco --> unica#{incorrectas_unica}"
      # p "corr --> unica#{correctas_unica}"
      # p "--------------------------"
      # p "--------------------------"
      p "inco --> Multiple#{incorrectas_multiple}"
      p "corr --> Multiple#{correctas_multiple}"
      p "--------------------------"
      p "--------------------------"
    end

    # Update tenrrollemt
    tenrollment.grade = nota_final
    tenrollment.tenrollment_status_id = 3
    tenrollment.attempts_counter = tenrollment.attempts_counter + 1
    tenrollment.save

    # Update nota in attempt
    attempt = Attempt.where("tenrollment_id = ?",tenrollment.id).first
    attempt.grade = nota_final
    attempt.save!
    
    # Si tiene una matricula actualizela
    tevacourse = TevaluationCourse.by_tevaluation_id(tevaluation.id)
    if tevacourse.any?
      enrol = Enrollment.by_user_id(tenrollment.user_id).by_course_id(tevacourse.first.course_id).first
      enrol.grade = nota_final
      enrol.save!
    end

    # TODO faltan los mails


    respond_to do |format|
      format.json { render :json => {:notamax => nota_max ,:nota => nota_final.to_f, :notamin=> notamin} }
    end

  end
  
  def responder
    
    # Trae la matricula
    @tenrollment = Tenrollment.find(params[:tenrollment_id])
    @tcategory = Tcategory.where("tevaluation_id = #{@tenrollment.tevaluation_id}").order(:id)

    # Un crso puede tener muchas evaluaciones
      # AQUI YA TRAE LAS CATEGORIAS y de esas trae la question
    @tcategories = Tcategory.where("tevaluation_id = #{@tenrollment.tevaluation_id}").all.map{|val| val.id}
    @questions = Question.where("tcategory_id IN (?)", @tcategories)
    
    # Tome el intento que el usuario quiere retomar
    @attempt = Attempt.find(params[:attemp_id])
    @btn_finish = enableButtonFinish( ThistoricEvaluation.where("tenrollment_id = ? AND attempt_id = ?", @tenrollment.id, @attempt.id))
    
  end
  
  def new_attempt
    @tenrollment = Tenrollment.find(params[:tenrrollment_id])
    @tcategories = Tcategory.where("tevaluation_id = #{@tenrollment.tevaluation_id}").all.map{|val| val.id}
    @questions = Question.where("tcategory_id IN (?)", @tcategories)

    # Crea un intento
    at = Attempt.new
    # Finaloza y termina con la misma fecha ???????? WTF
    at.startdate = Time.now
    at.endate = Time.now

    #porque no colocaar nota en cero ?
    at.grade = 0
    at.tenrollment_id = params[:tenrrollment_id]
    at.save!

    # Envia el intento nuevo
    @attempt = at

    # Reeditta  en tenrollment
    # El tenrollments guarda la nota del ultimo intento
    @tenrollment.grade = 0

    # Otra vez pone es estado (en curso)
    @tenrollment.tenrollment_status_id = 2
    @tevaluation = Tevaluation.find(@tenrollment.tevaluation_id)
    @tenrollment.timeleft = @tevaluation.tiempo_lim * 60
    @tenrollment.save! 

    @thistoric_evaluation_new = ThistoricEvaluation.new(:user_id => session[:user_id], 
                                :tenrollment_id => params[:tenrrollment_id], 
                                :attempt_id => @attempt.id)
                                
    @thistoric_evaluation_new.questions_list = @questions.map{ |q| q.id }.join('//')

    @thistoric_evaluation_new.save

    respond_to do |format|
      format.json { render :json => {:attemp_id => @attempt.id} }
    end

  end

  def saveDataEvaluation
    # Método para guardar las respestas del usuario según el intento
    array_answer_ids = params[:data_answer_ids]
    array_user_answer = params[:data_user_answer]
 
    array_user_answer_correct = []

    array_answer_ids.each do |z|
      array_user_answer_correct << Answer.find(z).correcta
    end

    @thistoric_evaluation = ThistoricEvaluation
                            .where("user_id = ? and tenrollment_id = ? and attempt_id = ?", 
                            params[:user_id],
                            params[:tenrollment_id], 
                            params[:attempt_id])

    hay_thistoricQuestion = ThistoricQuestion
                        .where("thistoric_evaluation_id = ? and question_id = ? ", 
                          @thistoric_evaluation.first.id,
                          params[:question_id])

    # Buscar el thistoric_question
    if hay_thistoricQuestion.any?
      #EDITE thistoric_question, SI EXISTE 

      @thistoricQuestion_actual = hay_thistoricQuestion.first
    else
      #Cree un new thistoric_question, NO EXISTE
      @thistoric_question_new = ThistoricQuestion.new(:thistoric_evaluation_id => @thistoric_evaluation.first.id, 
                                                  :question_id => params[:question_id])

      @thistoric_question_new.save!
      @thistoricQuestion_actual = @thistoric_question_new
    end

    # Ahora a guadar las respuestas
      array_answer_ids.each_with_index do |answer,index|
        thistoric_answer = ThistoricAnswer.where("thistoric_question_id = ? and answer_id = ?",
                                @thistoricQuestion_actual.id,
                                answer)

          #Set Names correcto o incorrecto
          if (array_user_answer[index].to_i == array_user_answer_correct[index].to_i) && array_user_answer_correct[index].to_i == 1
            text = "Correcto" 
          else
            text = "Incorrecto" 
          end


        if thistoric_answer.any?
          #Edite las respuestas

          thistoric_answer.first.update_attributes(
            :answer_id => answer, 
            :user_answer => array_user_answer[index], 
            :correct_answer => array_user_answer_correct[index], 
            :name_result => text)

        else
          #Cree las respuestas
          @thistoric_answer = ThistoricAnswer.new(
            :thistoric_question_id => @thistoricQuestion_actual.id,
            :answer_id => answer, 
            :user_answer => array_user_answer[index], 
            :correct_answer => array_user_answer_correct[index], 
            :name_result => text)

            @thistoric_answer.save!
        end
      end

    btn_finish = enableButtonFinish(@thistoric_evaluation)
    
    respond_to do |format|
      format.json { render :json => {:uno => @thistoricQuestion_actual.id,:btn_end => btn_finish} }
    end
  end

  #METODO PARA VALIDAR SI SE PUEDE HABILITAR BOTON DE GUARDAR FINALIZAR
  def enableButtonFinish(thistoric_evaluation)

    list_question = thistoric_evaluation.first.questions_list.split('//')

    
    thisto_quiestions = ThistoricQuestion.where("question_id IN (?) AND thistoric_evaluation_id = ?",
                                            list_question.map {|x| x}, 
                                            thistoric_evaluation.first.id).all

    # Si son igaules significa que ya respondio todas las preguntas
    list_question.size == thisto_quiestions.size
  
  end

  def changeStatus
    @tenrollment = Tenrollment.find(params[:tenrollment_id])
    @tenrollment.update_attributes(:tenrollment_status_id => 3)
    return true
  end

	def tevaluation_course
    flash.notice = nil

		tevaluation_courses = TevaluationCourse.all

    if tevaluation_courses.any?
      @tevaluation_filter = Tevaluation.where('id NOT IN(?)', tevaluation_courses.map { |t| t.tevaluation_id }).order("nombre ASC").all
    else
      @tevaluation_filter = Tevaluation.order(:nombre)
    end
    
    @tevaluation_id = params[:f1][:f1] if params[:f1]

		if params[:f1] and Tevaluation.exists?(params[:f1][:f1])
			@tevaluation_id = params[:f1][:f1]
			@courses = Course.where('course_status_id=1').order('name')
			# @users = @users.select('DISTINCT id, _id')

			if params[:find_course].present?
				@find_course = params[:find_course]
				courses = Course.where("name like ?", "%#{params[:find_course]}%").select(:id).map {|c| c.id }
	      course_objects = CourseObject.where("title like ? and course_object_status_id = 1 and course_object_type_id >= 3", "%#{params[:find_course]}%").map {|o| o.course_id }
	      courses_array = courses + course_objects
				@courses = @courses.where("id IN (?)", courses_array)
			end
		end

    msg = ""
    if params[:course_ids] and params[:thecourse_id]
      coursearr = params[:course_ids]
      evalid = params[:thecourse_id]
      teval = Tevaluation.find(evalid)

			for si in coursearr
        course = Course.find(si.to_i)
        if !course.more_than_one_evaluation
          if TevaluationCourse.where("course_id = ?", course.id).any?
            msg = "El curso #{course.name} no puede tener más de una evaluación, por favor revise y vuelva a asignar."
            break
          end
        end
        if course.course_type_id == 1
          course.without_score = 1
          course.save
        end
				en = nil
				en = TevaluationCourse.by_tevaluation_id(evalid).by_course_id(si.to_i).first
				if !en
					en = TevaluationCourse.new
				end

				en.course_id = si.to_i
				en.tevaluation_id = evalid
				en.save!
			end
		end
    if msg != ""
      flash.notice = msg
    end
	end

  def asignacion_masiva
    flash[:notice] = ""
		@tevaluation_filter = Tevaluation.order(:nombre)
		@company_filter = Company.order(:name)
		@position_filter = Position.order(:name)
		@area_filter = Area.order(:name)
		@localization_filter = Localization.order(:name)
		@group_filter = Group.order(:name)
		@level_filter = Level.order(:name)
    @superior_filter = Area.order(:name)
    @manager_filter = User.where(status: 1).order(:second_name)
    # Realiza filtro de informacion
		unless params[:commit].blank?
			@users = User.where(status: 1).order(:second_name)
		  #  company
			@users = @users.where(company_id: params[:company_id]) unless params[:company_id].blank?
		  #  level
			@users = @users.where(position_id: Position.where(level_id: params[:level_id]).map{|a| a.id}.uniq) unless params[:level_id].blank?
		  #  localization
			@users = @users.where(localization_id: params[:localization_id]) unless params[:localization_id].blank?
		  #  area
			@users = @users.where(area_id: params[:area_id]) unless params[:area_id].blank?
		  #  grupo
			@users = @users.where(group_id: params[:group_id]) unless params[:group_id].blank?
		  #  position
			@users = @users.where(position_id: params[:position_id]) unless params[:position_id].blank?
		  #  evaluator_id - Jefe
			@users = @users.where(manager_id: params[:manager_id]) unless params[:manager_id].blank?
    end
    # Realiza Asignaciones
		if params[:start_date_i] and params[:user_ids] and params[:thecourse_id]
			muser = User.find(session[:user_id])
			userarr = params[:user_ids]
			evalid = params[:thecourse_id]
			teval = Tevaluation.find(evalid)
			for si in userarr
				sim = User.find(si)
				# Todo: MATRICULAR!!!
				en = nil
				en = Tenrollment.by_tevaluation_id(evalid).by_user_id(sim.id).first
				if !en
					en = Tenrollment.new
          en.aditional_attempts = 0
        else
          en.aditional_attempts = en.aditional_attempts + 2
				end
				en.user_id = sim.id
				en.tevaluation_id = evalid
        en.tenrollment_status_id = 1
				en.enroll = Time.now
				en.limite = params[:start_date_i]
				en.grade = 0
        en.timeleft = en.tevaluation.tiempo_lim * 60
				if en.save!
          Notifier.evaluation_masive(sim, teval, params[:url_domain]).deliver
          flash[:notice] = "Usuarios asignados exitosamente."
        else
          flash[:notice] = "Usuarios No asignados."
        end
			end
		end
	end

  # GET /tevaluations
  # GET /tevaluations.xml
  def index
    # if User.find(session[:user_id]).profile_id != 1
    #  redirect_to :controller => "home", :action => "login"
    # else
      @tevaluations = Tevaluation.order('id desc')

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @tevaluations }
      end
    # end
  end

  # GET /tevaluations/1
  # GET /tevaluations/1.xml
	def show
		@tevaluation = Tevaluation.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @tevaluation }
		end
	end

  # GET /tevaluations/new
  # GET /tevaluations/new.xml
  def new
    @tevaluation = Tevaluation.new
    @tcategories = []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tevaluation }
    end
  end

  # GET /tevaluations/1/edit
  def edit
    @tevaluation = Tevaluation.find(params[:id])
    @tcategories = @tevaluation.tcategories
  end

  # POST /tevaluations
  # POST /tevaluations.xml
  def create
    @tevaluation = Tevaluation.new(params[:tevaluation])

    respond_to do |format|
      if @tevaluation.save
        format.html { redirect_to(edit_tevaluation_path(@tevaluation.id)) }
        format.xml  { render :xml => @tevaluation, :status => :created, :location => @tevaluation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tevaluation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tevaluations/1
  # PUT /tevaluations/1.xml
  def update
    @tevaluation = Tevaluation.find(params[:id])
    respond_to do |format|
      if @tevaluation.update_attributes(params[:tevaluation])
        format.html { redirect_to(edit_tevaluation_path(@tevaluation.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tevaluation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tevaluations/1
  # DELETE /tevaluations/1.xml
  def destroy
    @tevaluation = Tevaluation.find(params[:id])
    @tevaluation.destroy

    respond_to do |format|
      format.html { redirect_to(tevaluations_url) }
      format.xml  { head :ok }
    end
  end
end
