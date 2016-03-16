module.exports = function (grunt) {
	grunt.registerTask('prod', [
		'compileAssets',
		'concat',
		'uglify',
		'cssmin',
		'sails-linker:prodFrontendJs',
		'sails-linker:prodFrontendStyles',
		'sails-linker:prodAdminJs',
		'sails-linker:prodAdminStyles',
	]);
};
