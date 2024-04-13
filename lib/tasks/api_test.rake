namespace :api_test do
  desc "TODO"
  task get_data: :environment do
    feature = Feature.new
    feature.get_data
  end
end
