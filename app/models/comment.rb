class Comment < ApplicationRecord
    belongs_to :feature

    def self.create(feature_id, body)
    # return [id:feature_id, body:body]

        if is_numeric(feature_id)
            if !Feature.exists?(feature_id)
                return {"status" => "400", "message" => "La solicitud no puede continuar, debido a una sintaxis incorrecta con el campo 'id'.", "data" => []}
            end
            if body.length < 10
                return {"status" => "400", "message" => "El campo 'texto' debe ser mayor a 10'.", "data" => []}
            end 
            feature = Feature.find(feature_id)
            feature.comments.create(:feature_id => feature_id, :comment => body)
            {"status" => "200", "message" => "La solicitud se completo con exito'.", "data" => {"feature" => feature, "comments" => feature.comments}}
        else
            {"status" => "400", "message" => "La solicitud no se pudo entender debido a una sintaxis incorrecta con el campo 'id'.", "data" => []}
        end
    end
    def self.is_numeric(obj) 
        obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
     end
end
