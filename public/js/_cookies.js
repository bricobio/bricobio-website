// https://github.com/carhartl/jquery-cookie/tree/v1.4.1

$.cookie('the_cookie', 'the_value', { expires: 7, path: '/' });

$.cookie('the_cookie'); // => "the_value"
$.cookie('not_existing'); // => undefined