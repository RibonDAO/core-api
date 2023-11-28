class UserProfileBlueprint < Blueprinter::Base
  fields :name

    field(:photo) do |object|
    ImagesHelper.image_url_for(object.photo)
  end

  association :user, blueprint:UserBlueprint
end
