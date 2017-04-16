require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(
    ActionController::InvalidAuthenticityToken
    ActionController::BadRequest
    ActionController::UnknownFormat
    ActiveRecord::RecordNotUnique
  )

  config.ignore_if do |_exception, _options|
    !Rails.env.production?
  end

  if ENV['EXCEPTION_NOTIFICATION_EMAIL']
    # Email notifier sends notifications by email.
    config.add_notifier :email,
      email_prefix: '[pawoo-errors] ',
      sender_address: %W("pawoo Errors" <errors@#{ENV['SMTP_DOMAIN'] || Rails.configuration.x.local_domain}>),
      exception_recipients: ENV['EXCEPTION_NOTIFICATION_EMAIL'].split(',')
  end

  if Rails.application.secrets.slack['error_webhook_url'] && Rails.application.secrets.slack['error_channel']
    config.add_notifier :slack,
      webhook_url: Rails.application.secrets.slack['error_webhook_url'],
      channel: Rails.application.secrets.slack['error_channel']
  end
end
