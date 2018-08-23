@echo off
if exist "./wordpress/wp-config.php" (
	echo "WordPress config file found."

	SET /P REINSTALL= "Do you want to reinstall? [y/n] "

	if "y" == "%REINSTALL%" (
		docker-compose exec --user www-data phpfpm wp db reset --yes
	) else (
		echo "Installation aborted."
		exit 5
	)
)

REM Ask for the type of installation
SET /P MULTISITE=[Do you want a multisite installation? [y/n] ]

REM Install WordPress
docker-compose exec --user www-data phpfpm wp core download --force
docker-compose exec --user www-data phpfpm wp core config --force

if "y" == "%MULTISITE%" (
	docker-compose exec --user www-data phpfpm wp core multisite-install --prompt
) else (
	docker-compose exec --user www-data phpfpm wp core install --prompt
)

REM Adjust settings
docker-compose exec --user www-data phpfpm wp rewrite structure "/%postname%/"

REM Ask to remove default content ?
SET /P EMPTY_CONTENT=[Do you want to remove the default content? [y/n] ]

if "y" == "%EMPTY_CONTENT%" (
	REM Remove all posts, comments, and terms
	docker-compose exec --user www-data phpfpm wp site empty --yes

	REM Remove plugins and themes
	docker-compose exec --user www-data phpfpm wp plugin delete hello akismet
	docker-compose exec --user www-data phpfpm wp theme delete twentyfifteen twentysixteen

	REM Remove widgets
	docker-compose exec --user www-data phpfpm wp widget delete search-2 recent-posts-2 recent-comments-2 archives-2 categories-2 meta-2
)

echo "Installation done."
echo "------------------"
