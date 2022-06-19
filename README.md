# simpleCSS Generator
A simple script that implements some basic macros and configuration for generating CSS styles

## Configuration

**Sizes.cfg**

`Sizes.cfg` is a comma seperated configuration file
* Column 1: Generator set
* Column 2: Rule name
* Column 3: Rule value

## Example

**generate.sh**
```sh
...
css_size_prefix=( 'sm\\:' 'md\\:' 'lg\\:' )
css_size_rules=( 'max-width:600px' 'min-width:601px' 'min-width:1367px' )
css_size_count="${#css_size_prefix[@]}"
...
```

**Sizes.cfg**

```
A,25vw,25vw
A,large,200px
```

**rules.d/Width.css**

```css
.__SIZE__width-__NAME__ {
	width: __VALUE__;
}
```

**simple.css**
```css
/* Generated CSS */

@media only screen and (max-width:600px) {

	.sm\:width-25vw {
		width: 25vw;
	}

	.sm\:width-large {
		width: 200px;
	}
}

/* Repeat again for other media queries */
```
