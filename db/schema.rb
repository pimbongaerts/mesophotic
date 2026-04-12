# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_12_084721) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :integer, default: nil, force: :cascade do |t|
    t.integer "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "content"
    t.boolean "internal"
    t.boolean "request"
    t.boolean "request_handled"
    t.string "request_response"
    t.integer "user_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "eezs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "geoname", null: false
    t.integer "mrgid", null: false
    t.string "sovereign", null: false
    t.string "territory", null: false
    t.datetime "updated_at", null: false
    t.index ["mrgid"], name: "index_eezs_on_mrgid", unique: true
    t.index ["sovereign"], name: "index_eezs_on_sovereign"
  end

  create_table "expeditions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.date "end_date"
    t.string "featured_image_credits"
    t.date "start_date"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.integer "year"
  end

  create_table "expeditions_fields", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "field_id"
    t.index ["expedition_id"], name: "index_expeditions_fields_on_expedition_id"
    t.index ["field_id"], name: "index_expeditions_fields_on_field_id"
  end

  create_table "expeditions_focusgroups", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "focusgroup_id"
    t.index ["expedition_id"], name: "index_expeditions_focusgroups_on_expedition_id"
    t.index ["focusgroup_id"], name: "index_expeditions_focusgroups_on_focusgroup_id"
  end

  create_table "expeditions_locations", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "location_id"
    t.index ["expedition_id"], name: "index_expeditions_locations_on_expedition_id"
    t.index ["location_id"], name: "index_expeditions_locations_on_location_id"
  end

  create_table "expeditions_organisations", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "organisation_id"
    t.index ["expedition_id"], name: "index_expeditions_organisations_on_expedition_id"
    t.index ["organisation_id"], name: "index_expeditions_organisations_on_organisation_id"
  end

  create_table "expeditions_platforms", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "platform_id"
    t.index ["expedition_id"], name: "index_expeditions_platforms_on_expedition_id"
    t.index ["platform_id"], name: "index_expeditions_platforms_on_platform_id"
  end

  create_table "expeditions_users", id: false, force: :cascade do |t|
    t.integer "expedition_id"
    t.integer "user_id"
    t.index ["expedition_id"], name: "index_expeditions_users_on_expedition_id"
    t.index ["user_id"], name: "index_expeditions_users_on_user_id"
  end

  create_table "expertises_users", id: false, force: :cascade do |t|
    t.integer "expertise_id", limit: 4
    t.integer "user_id", limit: 4
    t.index ["expertise_id"], name: "index_expertises_users_on_expertise_id"
    t.index ["user_id"], name: "index_expertises_users_on_user_id"
  end

  create_table "fields", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description", limit: 255
    t.text "short_description"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "fields_publications", id: false, force: :cascade do |t|
    t.integer "field_id", limit: 4
    t.integer "publication_id", limit: 4
    t.index ["field_id"], name: "index_fields_publications_on_field_id"
    t.index ["publication_id"], name: "index_fields_publications_on_publication_id"
  end

  create_table "focusgroups", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description", limit: 255
    t.text "short_description"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "focusgroups_publications", id: false, force: :cascade do |t|
    t.integer "focusgroup_id", limit: 4
    t.integer "publication_id", limit: 4
    t.index ["focusgroup_id"], name: "index_focusgroups_publications_on_focusgroup_id"
    t.index ["publication_id"], name: "index_focusgroups_publications_on_publication_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "scope", limit: 255
    t.string "slug", limit: 255, null: false
    t.integer "sluggable_id", limit: 4, null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "journals", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "fullname"
    t.string "name", limit: 255
    t.boolean "open_access"
    t.datetime "updated_at", precision: nil, null: false
    t.text "website"
  end

  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description", limit: 255
    t.integer "eez_id"
    t.decimal "latitude", precision: 15, scale: 10
    t.decimal "longitude", precision: 15, scale: 10
    t.text "short_description"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["eez_id"], name: "index_locations_on_eez_id"
  end

  create_table "locations_publications", id: false, force: :cascade do |t|
    t.integer "location_id", limit: 4
    t.integer "publication_id", limit: 4
    t.index ["location_id"], name: "index_locations_publications_on_location_id"
    t.index ["publication_id"], name: "index_locations_publications_on_publication_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.date "end_date"
    t.string "featured_image_credits"
    t.date "start_date"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.string "venue"
    t.integer "year"
  end

  create_table "meetings_organisations", id: false, force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "organisation_id"
    t.index ["meeting_id"], name: "index_meetings_organisations_on_meeting_id"
    t.index ["organisation_id"], name: "index_meetings_organisations_on_organisation_id"
  end

  create_table "meetings_users", id: false, force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "user_id"
    t.index ["meeting_id"], name: "index_meetings_users_on_meeting_id"
    t.index ["user_id"], name: "index_meetings_users_on_user_id"
  end

  create_table "observations", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "depth"
    t.boolean "depth_estimate"
    t.integer "location_id"
    t.integer "observable_id"
    t.string "observable_type"
    t.integer "site_id"
    t.integer "species_id"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["observable_type", "observable_id"], name: "index_observations_on_observable_type_and_observable_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "country", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.string "name", limit: 255
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "organisations_photos", id: false, force: :cascade do |t|
    t.integer "organisation_id"
    t.integer "photo_id"
    t.index ["organisation_id"], name: "index_organisations_photos_on_organisation_id"
    t.index ["photo_id"], name: "index_organisations_photos_on_photo_id"
  end

  create_table "photos", force: :cascade do |t|
    t.boolean "contains_species"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "creative_commons", default: false
    t.string "credit"
    t.integer "depth"
    t.string "description"
    t.integer "expedition_id"
    t.integer "location_id"
    t.boolean "media_gallery", default: false
    t.integer "meeting_id"
    t.integer "photographer_id"
    t.integer "post_id"
    t.integer "publication_id"
    t.boolean "showcases_location", default: true
    t.integer "site_id"
    t.boolean "underwater", default: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "photos_platforms", id: false, force: :cascade do |t|
    t.integer "photo_id"
    t.integer "platform_id"
    t.index ["photo_id"], name: "index_photos_platforms_on_photo_id"
    t.index ["platform_id"], name: "index_photos_platforms_on_platform_id"
  end

  create_table "photos_users", id: false, force: :cascade do |t|
    t.integer "photo_id"
    t.integer "user_id"
    t.index ["photo_id"], name: "index_photos_users_on_photo_id"
    t.index ["user_id"], name: "index_photos_users_on_user_id"
  end

  create_table "platforms", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description", limit: 255
    t.text "short_description"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "platforms_publications", id: false, force: :cascade do |t|
    t.integer "platform_id", limit: 4
    t.integer "publication_id", limit: 4
    t.index ["platform_id"], name: "index_platforms_publications_on_platform_id"
    t.index ["publication_id"], name: "index_platforms_publications_on_publication_id"
  end

  create_table "platforms_users", id: false, force: :cascade do |t|
    t.integer "platform_id", limit: 4
    t.integer "user_id", limit: 4
    t.index ["platform_id"], name: "index_platforms_users_on_platform_id"
    t.index ["user_id"], name: "index_platforms_users_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "content_html", limit: 65535
    t.text "content_md", limit: 65535
    t.datetime "created_at", precision: nil
    t.boolean "draft", limit: 1, default: false
    t.integer "featured_publication_id"
    t.integer "featured_user_id"
    t.string "post_type"
    t.integer "postable_id"
    t.string "postable_type"
    t.string "slug", limit: 255
    t.string "title", limit: 255
    t.datetime "updated_at", precision: nil
    t.integer "user_id", limit: 4
    t.index ["postable_type", "postable_id"], name: "index_posts_on_postable_type_and_postable_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "presentations", force: :cascade do |t|
    t.text "abstract"
    t.text "authors"
    t.datetime "created_at", precision: nil, null: false
    t.string "date"
    t.string "location"
    t.integer "meeting_id"
    t.boolean "oral"
    t.integer "poster_id"
    t.string "session"
    t.string "time"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "presentations_users", id: false, force: :cascade do |t|
    t.integer "presentation_id", null: false
    t.integer "user_id", null: false
  end

  create_table "publications", force: :cascade do |t|
    t.string "DOI", limit: 255
    t.text "abstract", limit: 65535
    t.text "authors", limit: 65535
    t.text "behind_contents"
    t.string "book_authors"
    t.string "book_publisher", limit: 255
    t.string "book_title", limit: 255
    t.text "contents", limit: 65535
    t.integer "contributor_id"
    t.datetime "created_at", precision: nil, null: false
    t.text "external_id"
    t.string "filename", limit: 255
    t.string "issue", limit: 255
    t.integer "journal_id", limit: 4
    t.integer "max_depth", limit: 4
    t.boolean "mce", default: true
    t.boolean "mesophotic", limit: 1
    t.integer "min_depth", limit: 4
    t.boolean "new_species", limit: 1
    t.boolean "original_data", limit: 1
    t.string "pages", limit: 255
    t.string "publication_format", default: "article"
    t.string "publication_type"
    t.integer "publication_year", limit: 4
    t.string "title", limit: 255
    t.boolean "tme", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "url", limit: 255
    t.string "volume", limit: 255
    t.index ["contributor_id"], name: "index_publications_on_contributor_id"
    t.index ["journal_id"], name: "index_publications_on_journal_id"
    t.index ["publication_format"], name: "index_publications_on_publication_format"
    t.index ["publication_type"], name: "index_publications_on_publication_type"
    t.index ["publication_year"], name: "index_publications_on_publication_year"
    t.index ["updated_at"], name: "index_publications_on_updated_at"
  end

  create_table "publications_sites", id: false, force: :cascade do |t|
    t.integer "publication_id"
    t.integer "site_id"
    t.index ["publication_id"], name: "index_publications_sites_on_publication_id"
    t.index ["site_id"], name: "index_publications_sites_on_site_id"
  end

  create_table "publications_species", id: false, force: :cascade do |t|
    t.integer "publication_id", null: false
    t.integer "species_id", null: false
    t.index ["publication_id"], name: "index_publications_species_on_publication_id"
    t.index ["species_id"], name: "index_publications_species_on_species_id"
  end

  create_table "publications_users", id: false, force: :cascade do |t|
    t.integer "publication_id", limit: 4
    t.integer "user_id", limit: 4
    t.index ["publication_id"], name: "index_publications_users_on_publication_id"
    t.index ["user_id"], name: "index_publications_users_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "estimated", limit: 1
    t.decimal "latitude", precision: 15, scale: 10
    t.integer "location_id", limit: 4
    t.decimal "longitude", precision: 15, scale: 10
    t.string "site_name", limit: 255
    t.string "siteable_type", limit: 255
    t.datetime "updated_at", precision: nil, null: false
    t.index ["siteable_type"], name: "index_sites_on_siteable_type_and_siteable_id"
  end

  create_table "species", force: :cascade do |t|
    t.string "aims_webid"
    t.string "coraltraits_webid"
    t.datetime "created_at", precision: nil, null: false
    t.string "fishbase_webid"
    t.integer "focusgroup_id"
    t.string "name"
    t.string "region"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", force: :cascade do |t|
    t.text "address", limit: 65535
    t.string "alt_website", limit: 255
    t.string "bluesky_handle"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at", precision: nil
    t.string "country", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "department", limit: 255
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name", limit: 255
    t.string "google_scholar", limit: 255
    t.string "last_name", limit: 255
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip", limit: 255
    t.boolean "locked", limit: 1, default: false, null: false
    t.datetime "locked_at"
    t.string "mastodon_handle"
    t.integer "organisation_id", limit: 4
    t.text "other_organizations", limit: 65535
    t.string "phone", limit: 255
    t.datetime "remember_created_at", precision: nil
    t.text "research_interests", limit: 65535
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token", limit: 255
    t.string "role", default: "member", null: false
    t.integer "sign_in_count", limit: 4, default: 0, null: false
    t.string "threads_handle"
    t.string "title", limit: 255
    t.string "twitter_handle", limit: 255
    t.string "unconfirmed_email", limit: 255
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil
    t.string "website", limit: 255
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "validations", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "validatable_id"
    t.string "validatable_type"
    t.index ["user_id"], name: "index_validations_on_user_id"
    t.index ["validatable_type", "validatable_id"], name: "index_validations_on_validatable_type_and_validatable_id"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.text "object", limit: 1073741823
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "word_exclusions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "word", limit: 255
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "locations", "eezs"
end
