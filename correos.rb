#encoding: utf-8

class TevaluationsController < ApplicationController

	#layout :compute_layout

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

    if params[:evaluacion]
      ten.tenrollment_status_id = 3
      ten.save!
    end

    #puts params[:user_id].to_i
    #puts params[:tenrollment_id].to_i
    #puts params[:tiempo]

    return
  end

	def resultados
    @thistoric_evaluation = ThistoricEvaluation.new
		if params[:utf8] and params[:f]
			@nota = 0
			@tenrollment = Tenrollment.find(params[:f].keys.first)
      @attempt = Attempt.find(params[:hattempt_id])
			@tevaluation = @tenrollment.tevaluation

      if @tevaluation.random_questions
        @catarr = []
        # for sc in @tevaluation.tcategories
        if @tevaluation.categories_vs_questions
          @catarr = []

          thistoric_evaluation = ThistoricEvaluation.where("tenrollment_id = ?", @tenrollment.id).last
          thistoric_questions = ThistoricQuestion.where("thistoric_evaluation_id = ?", thistoric_evaluation.id)
          questions_tmp = Question.where("id IN (?)", thistoric_questions.map { |q| q.question_id }).order(:tcategory_id)
          questions_tmp = Question.where("id IN (?)", thistoric_evaluation.questions_list.split('//')).order(:tcategory_id)
          tcategories = Tcategory.where("id IN (?)", questions_tmp.map { |q| q.tcategory_id })

          # puts "==========================================="
          # puts "tcategories: #{tcategories.map { |c| c.id }}"
          # for sc in tcategories
            questionsarr = []

            # questions_tmp = sc.questions

            puts "==========================================="
            puts "questions_tmp: #{questions_tmp.map { |c| c.id }}"

          notapregunta = 0
          tcategories.each do |tcategory|
            category_grade = 0
            questions_tmp.where("tcategory_id = ?", tcategory.id).reorder(:tcategory_id).each do |question|
              incorrectas = 0
              correctas = 0
              question.answers.each do |answer|
                if answer.correcta != 0	# Si es correcta
                  puts 'r' + answer.id.to_s
                  if params['r' + answer.id.to_s]
                    correctas += 1
                  end
                else	# si es incorrecta
                  if params['r' + answer.id.to_s]
                    incorrectas += 1
                  end
                end
              end
              #correctas = sc.questions.size - incorrectas
              total_respuestas_correctas = Answer.where("question_id = ? and correcta = 1", question.id).all.size

              # notapregunta = 100 * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
              quantity_questions_category = questions_tmp.select(:tcategory_id).where("tcategory_id = ?", question.tcategory_id).group(:tcategory_id).count(:tcategory_id).sort_by { |key, value| value }.first[1]
              notapregunta = 100.0 / quantity_questions_category * ((correctas - incorrectas) / total_respuestas_correctas.to_f)
              puts "******notapregunta_sin_peso: 100 / #{quantity_questions_category} * ((#{correctas} - #{incorrectas}) / #{total_respuestas_correctas.to_f})"
              puts "......notapregunta_sin_peso: #{notapregunta}"
              puts "......questions_tmp.size.to_f: #{questions_tmp.select(:tcategory_id).where("tcategory_id = ?", question.tcategory_id).group(:tcategory_id).count(:tcategory_id).sort_by { |key, value| value }.first[1]}"
              puts "......correctas: #{correctas}"
              puts "......incorrectas: #{incorrectas}"
              puts "......total_respuestas_correctas.to_f: #{total_respuestas_correctas.to_f}"
              puts "......question.peso: #{question.peso}"

              puts "......tcategory_id: #{question.tcategory_id}"
              puts "......tcategory_id_peso: #{question.tcategory.peso}"
              notapregunta = notapregunta < 0 ? 0 : notapregunta * question.tcategory.peso / 100.0
              puts "......notapregunta: #{notapregunta}"
              category_grade += notapregunta
              # @catarr.push
            end
            # notacatfinal = notapregunta * sc.peso / 100
            @catarr.push category_grade
          end

            # notacat = 0.0
            # for i in questionsarr
            #   notacat += i
            # end
            # puts "sumatoria_pregunta_categoría#{sc.id}_peso: " + notacat.to_s
            # notacatfinal = notacat * sc.peso / 100
            # @catarr.push notacatfinal
          # end
        else
          questionsarr = []

          # if @tevaluation.random_questions
          thistoric_evaluation = ThistoricEvaluation.where("tenrollment_id = ?", @tenrollment.id).last
          thistoric_questions = ThistoricQuestion.where("thistoric_evaluation_id = ?", thistoric_evaluation.id)
          questions_tmp = Question.where("id IN (?)", thistoric_questions.map { |q| q.question_id })
          # else
          #   questions_tmp = sc.questions
          # end

          questions_tmp.each do |question|
            incorrectas = 0
            correctas = 0
            question.answers.each do |answer|
              if answer.correcta != 0	# Si es correcta
                puts 'r' + answer.id.to_s
                if params['r' + answer.id.to_s]
                  correctas += 1
                end
              else	# si es incorrecta
                if params['r' + answer.id.to_s]
                  incorrectas += 1
                end
              end
            end
            #correctas = sc.questions.size - incorrectas
            total_respuestas_correctas = Answer.where("question_id = ? and correcta = 1", question.id).all.size
            notapregunta = 100 / questions_tmp.size.to_f * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
            if @tevaluation.random_questions
              notapregunta = 100 / questions_tmp.size.to_f * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
              notapregunta = notapregunta < 0 ? 0 : notapregunta
            else
              notapregunta = 100 * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
              notapregunta = notapregunta < 0 ? 0 : notapregunta * question.peso / 100
            end
            questionsarr.push notapregunta
          end

          puts "............///......."
          puts "............///.......questionsarr.sum: #{questionsarr.sum}"
          puts "............///.......questionsarr.size.to_f: #{questionsarr.size.to_f}"
          # if @tevaluation.categories_vs_questions
          #   notacatfinal = questionsarr.sum * sc.peso / 100
          # else
            notacatfinal = questionsarr.sum
          # end
          puts "............///.......questionsarr.sum peso: #{notacatfinal}"
          @catarr.push notacatfinal
        end
        # end
      else
        @catarr = []
        for sc in @tevaluation.tcategories
          questionsarr = []

          if @tevaluation.random_questions
            thistoric_evaluation = ThistoricEvaluation.where("tenrollment_id = ?", @tenrollment.id).last
            thistoric_questions = ThistoricQuestion.where("thistoric_evaluation_id = ?", thistoric_evaluation.id)
            questions_tmp = Question.where("id IN (?)", thistoric_questions.map { |q| q.question_id })
          else
            questions_tmp = sc.questions
          end

          questions_tmp.each do |question|
            incorrectas = 0
            correctas = 0
            question.answers.each do |answer|
              if answer.correcta != 0	# Si es correcta
                puts 'r' + answer.id.to_s
                if params['r' + answer.id.to_s]
                  correctas += 1
                end
              else	# si es incorrecta
                if params['r' + answer.id.to_s]
                  incorrectas += 1
                end
              end
            end
            #correctas = sc.questions.size - incorrectas
            total_respuestas_correctas = Answer.where("question_id = ? and correcta = 1", question.id).all.size
            notapregunta = 100 / questions_tmp.size.to_f * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
            if @tevaluation.random_questions
              notapregunta = 100 / questions_tmp.size.to_f * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
              notapregunta = notapregunta < 0 ? 0 : notapregunta
            else
              notapregunta = 100 * ((correctas - incorrectas)/total_respuestas_correctas.to_f)
              notapregunta = notapregunta < 0 ? 0 : notapregunta * question.peso / 100
            end
            questionsarr.push notapregunta
          end

          if @tevaluation.random_questions
            puts "............///......."
            puts "............///.......questionsarr.sum: #{questionsarr.sum}"
            puts "............///.......questionsarr.size.to_f: #{questionsarr.size.to_f}"
            if @tevaluation.categories_vs_questions
              notacatfinal = questionsarr.sum * sc.peso / 100
            else
              notacatfinal = questionsarr.sum
            end
            puts "............///.......questionsarr.sum peso: #{notacatfinal}"
          else
            notacat = 0.0
            for i in questionsarr
              notacat += i
            end
            puts "sumatoria_pregunta_categoría#{sc.id}_peso: " + notacat.to_s
            notacatfinal = notacat * sc.peso / 100
          end
          @catarr.push notacatfinal
        end
      end

      @nota = 0.0
      puts "------------------------@catarr: #{@catarr}"
			for i in @catarr
				@nota += i
			end

			# at = Attempt.new
			# at.startdate = Time.now
			# at.endate = Time.now
			# at.grade = @nota
			# at.tenrollment_id = @tenrollment.id
			# at.save!
      @attempt.grade = @nota
      @attempt.save!
      @tenrollment.grade = @nota

      if TevaluationCourse.by_tevaluation_id(@tenrollment.tevaluation.id).any?
        tc = TevaluationCourse.by_tevaluation_id(@tenrollment.tevaluation.id).first
        enrol = Enrollment.by_user_id(@tenrollment.user_id).by_course_id(tc.course_id).first
        enrol.grade = @nota
        enrol.save!
      end

      @tenrollment.attempts_counter = @tenrollment.attempts_counter + 1
      @tenrollment.save!


			#@nota = @nota/100

			#tes = TevaluationScore.new
			#@nota += 33.33
		  @tcategory = Tcategory.first #.find(1)
			@questions = @tcategory.questions

      if TevaluationCourse.by_tevaluation_id(@tenrollment.tevaluation.id).any?

        # ENVIO AUTOMATICO DEL CORREO ELECTRONICO ===============================
        muser = User.find(session[:user_id])
        if @tevaluation.mail_approved # and session[:user_id].to_i == 380
          if enrol.grade >= enrol.course.mingrade and enrol.grade < 100
            # puts "******************approved2"
            Notifier.notification_answers_email(
              @tenrollment,
              @attempt,
              muser,
              @tevaluation.mail_approved_answer,
              "ha aprobado",
              true
            ).deliver
          end
        end

        if @tevaluation.mail_disapproved # and session[:user_id].to_i == 380
          if enrol.grade < enrol.course.mingrade
            # puts "******************disapproved2"
            Notifier.notification_answers_email(@tenrollment,
              @attempt,
              muser,
              @tevaluation.mail_disapproved_answer,
              "no ha aprobado, deberá repetir",
              false
            ).deliver
          end
        end
        # =======================================================================
      else
        # ENVIO AUTOMATICO DEL CORREO ELECTRONICO ===============================
        muser = User.find(session[:user_id])
        if @tevaluation.mail_approved # and session[:user_id].to_i == 380
          if @nota.to_f >= @tevaluation.nota_min.to_f and @nota.to_f < 100
            # puts "******************approved2"
            Notifier.notification_answers_email(
              @tenrollment,
              @attempt,
              muser,
              @tevaluation.mail_approved_answer,
              "ha aprobado",
              true
            ).deliver
          end
        end

        if @tevaluation.mail_disapproved # and session[:user_id].to_i == 380
          if @nota.to_f < @tevaluation.nota_min.to_f
            # puts "******************disapproved2"
            Notifier.notification_answers_email(@tenrollment,
              @attempt,
              muser,
              @tevaluation.mail_disapproved_answer,
              "no ha aprobado, deberá repetir",
              false
            ).deliver
          end
        end
        # =======================================================================
      end
		end
	end

	def responder
    @tenrollment = Tenrollment.find(params[:tenrollment_id])
    tenrollment_status_id = @tenrollment.tenrollment_status_id
    if tenrollment_status_id == 1 or tenrollment_status_id == 3
      at = Attempt.new
      at.startdate = Time.now
      at.endate = Time.now
      at.grade = @nota
      at.tenrollment_id = params[:tenrollment_id]
      at.save!
      @tenrollment.grade = 0
      @tevaluation = Tevaluation.find(@tenrollment.tevaluation_id)
      @tenrollment.timeleft = @tevaluation.tiempo_lim * 60
      @tenrollment.save!
    end

    @attempt = Attempt.where("tenrollment_id = #{params[:tenrollment_id]}").last


    @tcategory = Tcategory.where("tevaluation_id = #{@tenrollment.tevaluation_id}").order(:id)

    @tcategories = Tcategory.where("tevaluation_id = #{@tenrollment.tevaluation_id}").all.map{|val| val.id}
    @questions = Question.where("tcategory_id IN (?)", @tcategories)

    if @tenrollment.tevaluation.random_questions
      puts "************** aleatorio Activado"
      if @tenrollment.tevaluation.categories_vs_questions
        puts "************* Se tiene en cuenta las categorias"
        # total_questions_size = @questions.size
        # quantity_questions_show_per_category = total_questions_size / @tenrollment.tevaluation.number_questions_show
        # puts "******************-+quantity_questions_show_per_category: #{quantity_questions_show_per_category}"


        # SE DEBE VERIFICAR LA CATEGORIA CON EL MENOR NUMERO DE PREGUNTAS Y BASADO EN ESO DE CADA CATEGORIA PODER EXTRAER DE FORMA ALEATORIA LA MISMA CANTIDAD HALLADA.
        min_questions_category_and_value = @questions.select(:tcategory_id).group(:tcategory_id).count(:tcategory_id).sort_by { |key, value| value }
        min_questions_category = min_questions_category_and_value.first[1]

        # puts "---*****min_questions_category: #{min_questions_category.sort_by { |key, value| value }.first[1]}"

        array_questions = Array.new
        @tcategories.each do |tcategory|
          random_questions = @questions.where("tcategory_id = ?", tcategory).sample(min_questions_category)
          random_questions.each_with_index do |question, index|
            if index == (min_questions_category - 1)
              array_questions.push(question.id)
              break
            end
          end
        end

        puts "------------------------------------------array_questions: #{array_questions}"

        puts "-----------------------------------------***----/* array_questions.size: #{array_questions.size}"
        puts "-----------------------------------------***----/* @tenrollment.tevaluation.number_questions_show.to_i: #{@tenrollment.tevaluation.number_questions_show.to_i}"
        # if array_questions.size < @tenrollment.tevaluation.number_questions_show.to_i
        #   # random_tcategories = @tcategories.sample(@tcategories.size)

        #   # random_tcategories.each do |tcategory|
        #     random_questions = @questions.where("id NOT IN (?)", array_questions).sample(@questions.size)
        #     random_questions.each do |question|
        #       unless array_questions.include? question.id
        #         array_questions.push(question.id)
        #       end
        #       if array_questions.size == @tenrollment.tevaluation.number_questions_show.to_i
        #         break
        #       end
        #     end
        #     # if array_questions.size == @tenrollment.tevaluation.number_questions_show.to_i
        #     #   break
        #     # end
        #   # end
        # end

        number_questions_show = @tenrollment.tevaluation.number_questions_show

        while array_questions.size < number_questions_show
          # SE DEBE VERIFICAR QUE CATEGORÍAS AUN TIENEN PREGUNTAS PARA EXTRAER
          array_categories_with_questions = Array.new
          array_categories_with_questions = @questions.where("id NOT IN (?)", array_questions).map { |q| q.tcategory_id }.uniq
          # @questions.where("id NOT IN (?)", array_questions).each do |question|
          #   unless array_categories_with_questions.include? question.tcategory_id
          #     array_categories_with_questions.push question.tcategory_id
          #   end
          # end
          difference = number_questions_show.to_i - array_questions.size

          puts "difference: #{difference}"
          if difference.to_i > 0
            number_questions_per_category = difference / array_categories_with_questions.size
            number_missing_questions = difference % array_categories_with_questions.size

            # if number_questions_per_category == 0
            #   number_questions_per_category = number_missing_questions
            # end

            questions_missing = @questions.where("tcategory_id IN (?) AND id NOT IN (?)", array_categories_with_questions, array_questions)

            min_questions_category_and_value = questions_missing.select(:tcategory_id).group(:tcategory_id).count(:tcategory_id).sort_by { |key, value| value }
            min_questions_category = min_questions_category_and_value.first[1]

            # puts "min_questions_category: #{min_questions_category}"
            # puts "number_questions_per_category: #{number_questions_per_category}"
            # puts ".... #{min_questions_category} > #{number_questions_per_category}"

            if number_questions_per_category.to_i == 0 # Quiere decir que hay un numero de preguntas menor a la cantidad de categorías de donde se pueden extraer preguntas
              array_categories_with_questions = array_categories_with_questions.sample(number_missing_questions)
              questions_missing = @questions.where("tcategory_id IN (?) AND id NOT IN (?)", array_categories_with_questions, array_questions)
              # puts "-----questions_missing: #{questions_missing.to_sql}"
              array_categories_with_questions.each do |tcategory_id|
                loop do
                  @questions_missing_tmp = questions_missing.where("tcategory_id = ?", tcategory_id).sample(number_missing_questions).map { |q| q.id }
                  # puts "(#{@questions_missing_tmp} & #{array_questions}).empty? #{(@questions_missing_tmp & array_questions).empty?}"
                  break (@questions_missing_tmp & array_questions).empty?
                end
                array_questions.concat(@questions_missing_tmp)
              end
            else
              if min_questions_category.to_i > number_questions_per_category
                # puts " entraaaaaaaaaaa"
                array_categories_with_questions.each do |tcategory_id|
                  loop do
                    @questions_missing_tmp = questions_missing.where("tcategory_id = ?", tcategory_id).sample(number_questions_per_category).map { |q| q.id }
                    puts "(#{@questions_missing_tmp} & #{array_questions}).empty? #{(@questions_missing_tmp & array_questions).empty?}"
                    break (@questions_missing_tmp & array_questions).empty?
                  end
                  array_questions.concat(@questions_missing_tmp)
                end
              else
                puts " entraaaaaaaaaaa222222"
                array_categories_with_questions.each do |tcategory_id|
                  puts "----------category: #{tcategory_id}"
                  loop do
                    puts "---------lasdjlsdjflakdf"
                    @questions_missing_tmp = questions_missing.where("tcategory_id = ?", tcategory_id).sample(min_questions_category).map { |q| q.id }
                    puts "#{@questions_missing_tmp} & #{array_questions}"
                    break (@questions_missing_tmp & array_questions).empty?
                  end
                  array_questions.concat(@questions_missing_tmp)
                end
              end
            end

            # puts "------------------------------------------****array_questions: #{array_questions}"
          end
        end
        # puts "------------------------------------------****array_questions_final: #{array_questionsl}"

        # puts "////////////////>>array_categories_with_questions: #{array_categories_with_questions}"

        # puts "------------------------------------------****array_questions_final: #{array_questionsl}"

        @questions = @questions.where("id IN (?)", array_questions)
        thistoric_evaluation = ThistoricEvaluation.where("user_id = ? and tenrollment_id = ? and attempt_id = ?", session[:user_id], params[:tenrollment_id], @attempt.id)

        if thistoric_evaluation.any?
          if thistoric_evaluation.first.questions_list.nil?
            # @questions = @questions.where("id IN (?)", @array_questions_random)
            @questions = Question.where("id IN (?)", array_questions)
          else
            @questions = Question.where("id IN (?)", thistoric_evaluation.first.questions_list.split("//"))
          end
        end

        @tcategory = Tcategory.where("id IN (?)", @questions.map{ |c| c.tcategory_id })
      else
        # puts "************* No se tiene en cuenta las categorias"
        array_questions = @questions.map{ |q| q.id }
        @array_questions_random = array_questions.sample(@tenrollment.tevaluation.number_questions_show)
        # puts "-------------array_questions_random: #{@array_questions_random}"
        @questions = @questions.where("id IN (?)", @array_questions_random)
        thistoric_evaluation = ThistoricEvaluation.where("user_id = ? and tenrollment_id = ? and attempt_id = ?", session[:user_id], params[:tenrollment_id], @attempt.id)

        if thistoric_evaluation.any?
          if thistoric_evaluation.first.questions_list.nil?
            @questions = Question.where("id IN (?)", @array_questions_random)
          else
            @questions = Question.where("id IN (?)", thistoric_evaluation.first.questions_list.split("//"))
          end
        end
        @tcategory = Tcategory.where("id IN (?)", @questions.map{ |c| c.tcategory_id })
      end
    end

		#@questions = @tcategory.questions
    @tenrollment.tenrollment_status_id = 2
    @tenrollment.save!
	end

  def saveDataEvaluation
    # Método para guardar las respestas del usuario según el intento
    array_answer_ids = params[:data_answer_ids].split(",");  #Vector para
    array_user_answer = params[:data_user_answer].split(",");
    array_correct_answers = params[:data_correct_answers].split(",");
    last_index = params[:last_index].to_i

    @thistoric_evaluation = ThistoricEvaluation.where("user_id = ? and tenrollment_id = ? and attempt_id = ?", params[:user_id], params[:tenrollment_id], params[:attempt_id])

    @result = false

    if @thistoric_evaluation.any? #if 1
      #=====================================================================
      # Si existe registro en thistoric_evaluation
      #=====================================================================
      #puts "array_answer_ids: #{array_answer_ids}"
      #puts "array_user_answer: #{array_user_answer}"
      #puts "array_correct_answers: #{array_correct_answers}"
      #puts "last_index: #{last_index}"

      @thistoric_question = ThistoricQuestion.where("thistoric_evaluation_id = #{@thistoric_evaluation.first.id} and question_id = #{params[:question_id]}")

      if @thistoric_question.any? #if 4
        #===================================================================
        # Si existe registro en thistoric_question
        #===================================================================
        #if @thistoric_evaluation.random_questions
        #else
          @thistoric_answer = ThistoricAnswer.where("thistoric_question_id = #{@thistoric_question.first.id}")
        #end

        if @thistoric_answer.any? #if 6
          #=================================================================
          # Si existe registro en thistoric_answer
          #=================================================================
          counter = 0
          @thistoric_answer.each do |thistoric_answer| #do 2
            #===============================================================
            # Se actualizan las respuestas
            #===============================================================
            thistoric_answer.update_attributes(:user_answer => array_user_answer[counter])
            counter += 1
            @result = true
          end #end do 2
        else #else if 6
          #=================================================================
          # Si NO existe registro en thistoric_answer
          #=================================================================
           last_index.times do |num| #do 3

            @thistoric_answer = ThistoricAnswer.new(:thistoric_question_id => @thistoric_question.first.id, :answer_id => array_answer_ids[num], :user_answer => array_user_answer[num], :correct_answer => array_correct_answers[num], :name_result => array_user_answer[num] == array_correct_answers[num] ? "correct" : "Incorrect")
            if @thistoric_answer.save
              @result = true
            else
              @result = false
            end
          end #end do 3
        end #end if 6
      else  #else if 4
        @thistoric_question = ThistoricQuestion.new(:thistoric_evaluation_id => @thistoric_evaluation.first.id, :question_id => params[:question_id])

        if @thistoric_question.save #if 5

          last_index.times do |num| #do 1

            @thistoric_answer = ThistoricAnswer.new(:thistoric_question_id => @thistoric_question.id, :answer_id => array_answer_ids[num], :user_answer => array_user_answer[num], :correct_answer => array_correct_answers[num], :name_result => (array_user_answer[num].to_i == array_correct_answers[num].to_i ? "correct" : "Incorrect"))
            @thistoric_answer.save
            if @thistoric_answer.save
              @result = true
            else
              @result = false
            end
          end #end do 1

        end #end if 5

      end #end if 4

    else  #else if 1
      #=====================================================================
      # Si no existe registro en thistoric_evaluation
      #=====================================================================
      @thistoric_evaluation = ThistoricEvaluation.new(:user_id => params[:user_id], :tenrollment_id => params[:tenrollment_id], :attempt_id => params[:attempt_id])
      if @thistoric_evaluation.save   #if 2
        #===================================================================
        # Crea registro en thistoric_question
        #===================================================================
        @thistoric_question = ThistoricQuestion.new(:thistoric_evaluation_id => @thistoric_evaluation.id, :question_id => params[:question_id])
        if @thistoric_question.save #if 3

          last_index.times do |num| #do 1
            #===============================================================
            # Crea registros en thistoric_answer
            #===============================================================
            @thistoric_answer = ThistoricAnswer.new(:thistoric_question_id => @thistoric_question.id, :answer_id => array_answer_ids[num], :user_answer => array_user_answer[num], :correct_answer => array_correct_answers[num], :name_result => array_user_answer[num] == array_correct_answers[num] ? "correct" : "Incorrect")
             @thistoric_answer.save

          end #end do 1
          @result = true
        else #else if 3
          @result = false
        end #end if 3
        @result = true

      else  #else if 2

        @result = false

      end   #end if 2
      #=====================================================================
    end #end if 1

    @result = @result ? "***true***" : "***false***"

    return @result
  end

  #METODO PARA VALIDAR SI SE PUEDE HABILITAR BOTON DE GUARDAR FINALIZAR
  def enableButtonFinish
    user_id = params[:user_id]
    tenrollment_id = params[:tenrollment_id]
    attempt_id = params[:attempt_id]

    tevaluation_id = Tenrollment.find(tenrollment_id).tevaluation_id
    @tcategories = Tcategory.where("tevaluation_id = #{tevaluation_id}")
    array_question_ids = Array.new
    counter = 0
    tevaluation_tmp = Tevaluation.find(tevaluation_id)
    @thistoric_evaluation = ThistoricEvaluation.where("user_id = #{user_id} and tenrollment_id = #{tenrollment_id} and attempt_id = #{attempt_id}")
    if @thistoric_evaluation.any?
      if tevaluation_tmp.random_questions
        @questions = Question.where("id IN (?)", @thistoric_evaluation.first.questions_list.split("//"))
      else
        @tcategories.each do |tcategory|
          @questions = Question.where("tcategory_id = #{tcategory.id}")
          @questions.each do |question|
            array_question_ids[counter] = question.id
            counter += 1
          end
        end
      end
    end

    puts array_question_ids

    @result = "***false***"
    if @thistoric_evaluation.any?
      thistoric_evaluation_id = @thistoric_evaluation.first.id
      @thistoric_questions = ThistoricQuestion.where("thistoric_evaluation_id = #{thistoric_evaluation_id}")

      if tevaluation_tmp.random_questions
        size_array_questions = @questions.size
        puts "..........................++++"
      else
        size_array_questions = array_question_ids.length
        puts "..........................----"
      end
      puts "...................size_array_questions: #{size_array_questions}"

      if size_array_questions == @thistoric_questions.size
        @result = "***true***"
      else
        @result = "***false***"
      end
    else
       @result = "***false***"
    end

    return @result
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

    puts "params[:tevaluation]: #{params[:tevaluation].inspect}"

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
