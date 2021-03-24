class VolatilityQuestionsController < ApplicationController
  #before_filter :load_question, only: [:show,:destroy,:edit,:update,:destroy]
  def index
    
    @volatility_questions = VolatilityQuestion.order('volatility_question_type_id, updated_at desc')
    
    if params[:estado].present? && !params[:estado].nil? 
       @volatility_questions = @volatility_questions.where("state = ?", params[:estado])
       @actual_estate =  params[:estado]
    end
    if params[:tipo].present? && !params[:tipo].nil? 
      @volatility_questions = @volatility_questions.where("volatility_question_type_id = ?", params[:tipo])
      @actual_tipo =  params[:tipo]
    end

  end

  def show
  end

  def edit
    load_question
    @volatility_question_type = VolatilityQuestionType.all
  end

  def update
    load_question
     
    if @volatility_question.update_attributes(params[:volatility_question])
      @result = "Pregunta editada Satisfactoriamente"
    else
      @result = "Error al editar la pregunta"
    end
    redirect_to action: 'index'
    # if @volatility_question.update_attributes(params[:volatility_question])
    #   delete_answers=params["volatility_answer"]["delete_all"]
    #   if ! delete_answers.blank? && delete_answers==1
    #     @volatility_question.user_questions.update_all(score: nil)
    #     @volatility_question.user_questions.each{|uq| uq.user.calculate_volatility(vc.volatility_question_type)}
    #   end
    #     @result = "Pregunta Creada Satisfactoriamente"

    # else
    #   @result = "Error al crear la pregunta"
    # end

  end

  def new
    @volatility_question=VolatilityQuestion.new
    @volatility_question_type=VolatilityQuestionType.all
  end

  def create
    @volatility_question = VolatilityQuestion.new(params[:volatility_question])
    if @volatility_question.save
      @result = "Pregunta editada Satisfactoriamente"
    else
      @result = "Error al editar la pregunta"
    end
    redirect_to action: 'index'

  end

  def destroy
    load_question
    # users_ids=@volatility_question.user_questions.collect{|uq|uq.user.id}
    # user=User.find_all_by_id users_ids
    # type=@volatility_question.volatility_question_type
    if @volatility_question.destroy
      @result = "Pregunta eliminada Satisfactoriamente"
      # user.each{|u| u.calculate_volatility(type)}
    else
      @result = "Error al eliminar la pregunta"
    end
    redirect_to action: 'index', :notice => @result
  end

 private

  def load_question
    @volatility_question= VolatilityQuestion.find_by_id(params[:id])
  end

  def volatility_questions_params
    params.require(:volatility_question).permit(:description,:volatility_question_type_id, :state)
  end
end

