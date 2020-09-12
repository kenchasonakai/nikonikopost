class PostsController < ApplicationController
  def create
		responses = params[:responses].permit!.to_hash
		@post_body = {body: post_text(responses)}
		render :json => @post_body 
	end

  private

  def post_params
    params.require(:post).permit(:post_name, :image)
  end

  def post_text(responses)
		response = responses["0"] if responses
		if response
			safesearch = response["safeSearchAnnotation"]
			faceAnnotations = response["faceAnnotations"]
			bestGuessLabels = response["webDetection"]["bestGuessLabels"]["0"]["label"]
			label = "ふむふむ、#{bestGuessLabels}じゃな <br>"
		end
		
		faceAnnotation = faceAnnotations["0"] if faceAnnotations
		
		if safesearch
			adult_decision = safesearch["adult"]
			violence_decision = safesearch["violence"]
			safesearch = [adult_decision, violence_decision]

			if adult_decision == "VERY_LIKELY"
				adult_level = "これはとてもエチチな画像じゃ <br>"
			elsif adult_decision == "LIKELY"
				adult_level = "これはエッチな画像じゃ！けしからんぞい <br>"
			elsif adult_decision == "POSSIBLE"
				adult_level = "これはエッチな画像の可能性があるぞいこっそり見るんじゃぞ <br>"
			else
				adult_level = ""
			end

			if violence_decision == "VERY_LIKELY"
				violence_level = "暴力はよくないぞい <br>"
			elsif violence_decision == "LIKELY"
				violence_level = "暴力はよくないぞい <br>"
			elsif violence_decision == "POSSIBLE"
				violence_level = "これはバイオレンスな画像の可能性がポッシボウじゃ <br>"
			else
				violence_level = ""
			end
		end

		if faceAnnotation
			#楽しさ
			joyLikelihood = faceAnnotation["joyLikelihood"]
			#悲しみ
			sorrowLikelihood = faceAnnotation["sorrowLikelihood"]
			#怒り
			angerLikelihood  = faceAnnotation["angerLikelihood"]
			#驚き
			surpriseLikelihood  = faceAnnotation["surpriseLikelihood"]
			#"VERY_LIKELY", "LIKELY", "POSSIBLE", "UNLIKELY", "VERY_UNLIKELY"
			if joyLikelihood == "VERY_LIKELY"
				joy = "とってもいい笑顔じゃ喜びボルテージがマックスじゃ <br>"
			elsif joyLikelihood == "LIKELY"
				joy = "うむいい笑顔じゃのやっぱり笑顔が一番じゃ <br>"
			elsif joyLikelihood == "POSSIBLE"
				joy = "いい笑顔じゃの楽しい雰囲気が伝わってくるわい <br>"
			else
				joy = ""
			end

			if sorrowLikelihood == "VERY_LIKELY" || sorrowLikelihood == "LIKELY" || sorrowLikelihood == "POSSIBLE"
				sorrow = "悲しそうな顔をしとるのぅいいことがあるといいのう <br>"
			else 
				sorrow = ""
			end

			if angerLikelihood == "VERY_LIKELY" || angerLikelihood == "LIKELY" || angerLikelihood == "POSSIBLE"
				anger = "怒っておるの激おこぷんぷん丸じゃ <br>"
			else 
				anger = ""
			end
			
			if surpriseLikelihood == "VERY_LIKELY" || surpriseLikelihood == "LIKELY" || surpriseLikelihood == "POSSIBLE"
				surprise = "びっくりしておるのう何があったんじゃ <br>"
			else 
				surprise = ""
			end
			emotion = "#{joy}#{sorrow}#{anger}#{surprise}"
		end

		return post_boby = "#{label}#{adult_level}#{violence_level}#{emotion}"
  end
end
