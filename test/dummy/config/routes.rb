Rails.application.routes.draw do
  mount EventLogging::Engine => "/event_logging"
end
