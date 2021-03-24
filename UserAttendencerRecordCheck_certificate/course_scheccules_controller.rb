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
