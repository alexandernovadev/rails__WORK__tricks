  def evaluate
    question_type = params[:volatility_question_type]
    @questions = VolatilityQuestion.where(volatility_question_type_id:question_type, state:1)
    @user_questions = []
    @user = User.find(params[:id])
    @project = Project.find(params[:search][:project])
    @questions.each do |question|
     @user_questions << UserQuestion.find_or_create_by_user_id_and_project_id_and_volatility_question_id(@user.id, @project.id, question.id)
    end
  end

