ACCESS_KEY_ID = Rails.application.credentials.dig(:aws, :access_key_id)
SECRET_ACCESS_KEY = Rails.application.credentials.dig(:aws, :secret_access_key)

BUCKET_NAME = "mesophotic.org"
DATABASE_NAME = "production.sqlite3"
DATABASE_DIR = Rails.root.join("db")
DATABASE_PATH = "#{DATABASE_DIR}/#{DATABASE_NAME}"
STORAGE_DIR = Rails.root.join("storage")

YEAR = `TZ=Australia/Brisbane date "+%Y"`.chomp
COMPRESSED_DATABASE_NAME = `TZ=Australia/Brisbane date "+%Y%m%d-#{DATABASE_NAME}.xz"`.chomp
COMPRESSED_DATABASE_PATH = "#{DATABASE_DIR}/#{COMPRESSED_DATABASE_NAME}"

namespace :backup do
  desc "Backup database to AWS S3"
  task db: :environment do
    puts `TZ=Australia/Brisbane date "+%Y%m%d: Database backup to AWS S3"`

    compress_database
    upload_compressed_database_to_s3
    cleanup_compressed_database
  end

  desc "Backup storage to AWS S3"
  task storage: :environment do
    puts `TZ=Australia/Brisbane date "+%Y%m%d: Storage sync to AWS S3"`

    sync_storage_to_s3
  end

  private

  def compress_database
    puts "-- Compressing database..."

    unless system "tar cvf #{COMPRESSED_DATABASE_PATH} --use-compress-program='xz -T0' #{DATABASE_PATH}"
        raise RuntimeError.new("SQLITE3::COMPRESSION::Failed #{`TZ=Australia/Brisbane date`}")
    end
  end

  def upload_compressed_database_to_s3
    puts "-- Uploading compressed database..."

    system(
      """
      AWS_ACCESS_KEY_ID=#{ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY=#{SECRET_ACCESS_KEY}
      aws s3 cp #{COMPRESSED_DATABASE_PATH} s3://#{BUCKET_NAME}/Backups/db/#{COMPRESSED_DATABASE_NAME}
      """
    )
  end

  def cleanup_compressed_database
    puts "-- Cleaning up..."

    system "rm #{COMPRESSED_DATABASE_PATH}"
  end

  def sync_storage_to_s3
    puts "-- Synchronizing storage..."

    system(
      """
      AWS_ACCESS_KEY_ID=#{ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY=#{SECRET_ACCESS_KEY}
      aws s3 sync #{STORAGE_DIR} s3://#{BUCKET_NAME}/Backups/storage
      """
    )
  end
end
