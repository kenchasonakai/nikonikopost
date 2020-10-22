class PostsController < ApplicationController
  def create
    responses = params[:responses].permit!.to_hash
    @post_body = { body: post_text(responses) }
    render json: @post_body
  end

  private

  def post_params
    params.require(:post).permit(:post_name, :image)
  end

  def post_text(responses)
    response = responses['0'] if responses
    if response
      safesearch = response['safeSearchAnnotation']
      faceAnnotations = response['faceAnnotations']
      bestGuessLabels = response['webDetection']['bestGuessLabels']['0']['label']
      label = "ふむふむ、#{bestGuessLabels}じゃな <br>"
    end

    faceAnnotation = faceAnnotations['0'] if faceAnnotations

    if safesearch
      adult_decision = safesearch['adult']
      violence_decision = safesearch['violence']
      safesearch = [adult_decision, violence_decision]

      adult_level = if adult_decision == 'VERY_LIKELY'
                      'これはとてもエチチな画像じゃ <br>'
                    elsif adult_decision == 'LIKELY'
                      'これはエッチな画像じゃ！けしからんぞい <br>'
                    elsif adult_decision == 'POSSIBLE'
                      'これはエッチな画像の可能性があるぞいこっそり見るんじゃぞ <br>'
                    else
                      ''
                    end

      violence_level = if violence_decision == 'VERY_LIKELY'
                         '暴力はよくないぞい <br>'
                       elsif violence_decision == 'LIKELY'
                         '暴力はよくないぞい <br>'
                       elsif violence_decision == 'POSSIBLE'
                         'これはバイオレンスな画像の可能性がポッシボウじゃ <br>'
                       else
                         ''
                       end
    end

    if faceAnnotation
      # 楽しさ
      joyLikelihood = faceAnnotation['joyLikelihood']
      # 悲しみ
      sorrowLikelihood = faceAnnotation['sorrowLikelihood']
      # 怒り
      angerLikelihood  = faceAnnotation['angerLikelihood']
      # 驚き
      surpriseLikelihood = faceAnnotation['surpriseLikelihood']
      # "VERY_LIKELY", "LIKELY", "POSSIBLE", "UNLIKELY", "VERY_UNLIKELY"
      joy = if joyLikelihood == 'VERY_LIKELY'
              'とってもいい笑顔じゃ喜びボルテージがマックスじゃ <br>'
            elsif joyLikelihood == 'LIKELY'
              'うむいい笑顔じゃのやっぱり笑顔が一番じゃ <br>'
            elsif joyLikelihood == 'POSSIBLE'
              'いい笑顔じゃの楽しい雰囲気が伝わってくるわい <br>'
            else
              ''
            end

      sorrow = if sorrowLikelihood == 'VERY_LIKELY' || sorrowLikelihood == 'LIKELY' || sorrowLikelihood == 'POSSIBLE'
                 '悲しそうな顔をしとるのぅいいことがあるといいのう <br>'
               else
                 ''
               end

      anger = if angerLikelihood == 'VERY_LIKELY' || angerLikelihood == 'LIKELY' || angerLikelihood == 'POSSIBLE'
                '怒っておるの激おこぷんぷん丸じゃ <br>'
              else
                ''
              end

      surprise = if surpriseLikelihood == 'VERY_LIKELY' || surpriseLikelihood == 'LIKELY' || surpriseLikelihood == 'POSSIBLE'
                   'びっくりしておるのう何があったんじゃ <br>'
                 else
                   ''
                 end
      emotion = "#{joy}#{sorrow}#{anger}#{surprise}"
    end

    post_boby = "#{label}#{adult_level}#{violence_level}#{emotion}"
  end
end
