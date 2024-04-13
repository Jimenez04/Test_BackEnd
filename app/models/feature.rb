require 'uri'
require 'net/http'
require 'openssl'
require 'date'

class Feature < ApplicationRecord
    has_many :comments, dependent: :delete_all
    
    # add_foreign_key "children", "parents", on_delete: :cascade


    def get_data
        Feature.destroy_all
        url = URI("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.request(Net::HTTP::Get.new(url)).read_body
        response = JSON.parse(response)
        features  = response['features'].filter_map { |n| ["type" => n['type'], "external_id" => n['id'], "magnitude" => n['properties']['mag'],"place" => n['properties']['place'], "time" => n['properties']['time'], "tsunami" => n['properties']['tsunami'], "mag_type" => n['properties']['magType'], "title" => n['properties']['title'], "latitude" => n['geometry']['coordinates'][1], "longitude" => n['geometry']['coordinates'][2], "external_url" => n['properties']['url']] if ((n['properties']['time'].to_f / 1000).to_s).to_i   >= ((Time.now - (1.month)).to_i) && n['properties']['title'] != "" && n['properties']['url'] != "" && n['properties']['place'] != "" && n['properties']['magType'] != 'null' && n['properties']['mag'].to_f >=  -1.0 && n['properties']['mag'].to_f <=  10.0 && n['geometry']['coordinates'][1].to_f >=  -90.0 && n['geometry']['coordinates'][1].to_f <=  90.0 && n['geometry']['coordinates'][2].to_f > -180.0 && n['geometry']['coordinates'][2].to_f <=  180.0}.compact
        Feature.create(features)
      end

      def self.index(mag_type, per_page, page)
        if custom_validation(mag_type)
            features = mag_type != nil ? Feature.where(mag_type: mag_type).all().limit(per_page).offset((page.to_i-1)*per_page.to_i) : Feature.all().limit(per_page).offset((page.to_i-1)*per_page.to_i)
            features = features.filter_map { |n| {"id" => n.id, "type" => n.type, "attributes" => {"external_id" => n.external_id, "magnitude" => n.magnitude, "place" => n.place, "time" => n.time, "tsunami" => n.tsunami,"mag_type" => n.mag_type, "title" => n.title, "coordinates" => {"longitude" => n.longitude,"latitude" => n.latitude}},"links" => {"external_url" => n.external_url}}}.compact 
             {"status" => "200", "message" => "La solicitud se completo con exito'.", "data" => features, "pagination" => {"per_page" => per_page ,  "current_page" => page,  "total" =>  mag_type != nil ? ((Feature.where(mag_type: mag_type).all.count)/per_page.to_i)+1 : ((Feature.all.count)/per_page.to_i)+1} }
          else
            {"status" => "400", "message" => "La solicitud no se pudo entender debido a una sintaxis incorrecta con el campo 'MAG'.", "data" => []}
          end
      end 

      def self.get(id)
        if is_numeric(id)
            if !Feature.exists?(id)
                return {"status" => "400", "message" => "La solicitud no puede continuar, debido a una sintaxis incorrecta con el campo 'id'.", "data" => []}
            end
            feature = Feature.includes(:comments).find(id)
            {"status" => "200", "message" => "La solicitud se completo con exito'.", "data" => {"feature" => feature, "comments" => feature.comments}}
        else
            {"status" => "400", "message" => "La solicitud no se pudo entender debido a una sintaxis incorrecta con el campo 'id'.", "data" => []}
        end
    end
    
    private
    def self.custom_validation(mag_type)
      words = Set.new(["md", "ml", "ms", "mw", "me", "mi", "mb", "mlg"])
      if mag_type == nil
        return true
      end
        words.include?(mag_type) && mag_type.match(/[a-zA-Z]/)
    end
    private
    def self.is_numeric(obj) 
        obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
     end

end
