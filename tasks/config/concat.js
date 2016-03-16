/**
 * Concatenate files.
 *
 * ---------------------------------------------------------------
 *
 * Concatenates files javascript and css from a defined array. Creates concatenated files in
 * .tmp/public/contact directory
 * [concat](https://github.com/gruntjs/grunt-contrib-concat)
 *
 * For usage docs see:
 * 		https://github.com/gruntjs/grunt-contrib-concat
 */
module.exports = function(grunt) {

	grunt.config.set('concat', {
		frontendJs: {
			src: require('../pipeline').frontendJsFilesToInject,
			dest: '.tmp/public/js/frontend/production.frontend.js'
		},
		frontendCss: {
			src: require('../pipeline').frontendCssFilesToInject,
			dest: '.tmp/public/styles/frontend/production.frontend.css'
		},
		adminJs: {
		    src: require('../pipeline').adminJsFilesToInject,
		    dest: '.tmp/public/js/admin/production.admin.js'
		},
		adminCss: {
		    src: require('../pipeline').adminCssFilesToInject,
		    dest: '.tmp/public/styles/admin/production.admin.css'
		},
	});

	grunt.loadNpmTasks('grunt-contrib-concat');
};
