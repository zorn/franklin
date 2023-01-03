# Admin Content Flow

# TODO

* Maybe I should just focuses on "Articles" as a first pass since the others can come later (aren't consider part of mikezornek.com main blog right now) would allow me to launch eralier.


I expect to visit the URL `/admin` to see tools that let me manage and add content to the site.

`/admin` should be hidden by some kind of authentication wall, though in the begining I expect we can use basic HTTP as we will make the assumption that all content authorship is Mike Zornek.

When I am in the admin area I expect to 

## Create New Article

Articles are longer form content. The content will be entered in Markdown and we expect rendered in HTML.

Title (plain-text)

Summary (Markdown) -- usually only one paragraph but we might want to test for multiple.

Content (or body?) (Markdown)

When editing content I expect to be able to drag and drop media like pngs or animated gifs into the editor and have the asset uploaded somewhere and appriopiate media inserted into the markdown

I should be able to save as draft (and it should auto-save as draft often)

I should be able to Publish as well (which uses current time as published at)

## Create New Social Post

Social posts are smaller and the editing tools should enforce expected lengths.

I don't think we want the social post content to be in markdown since that is not how they will be syndicated to Twitter/Mastodon.

I should be able to attach media to the post, including images or movies. Attaching is important

## Create New Video

Title 

Thumbnail 
would be cool to have a thumbnail editor

Content (as seen in the text area under a YouTube video)
