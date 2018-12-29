<?php

namespace {

    use SilverStripe\AssetAdmin\Forms\UploadField;
    use SilverStripe\Assets\Image;
    use SilverStripe\CMS\Model\SiteTree;

    class Page extends SiteTree
    {
        private static $db = [];

        private static $has_one = [
            'FeaturedImage' => Image::class
        ];

        private static $owns = [
            'FeaturedImage'
        ];

        public function getCMSFields()
        {
            $fields = parent::getCMSFields();
            $fields->addFieldsToTab('Root.Attachments', $featuredImage = UploadField::create('FeaturedImage'));
            $featuredImage->setFolderName('featured-image');

            return $fields;
        }
    }
}
