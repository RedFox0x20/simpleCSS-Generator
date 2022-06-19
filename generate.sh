#!/bin/bash
# generate.sh

echo -e "\nsimpleCSS Generator\nLoading rules...\n"

# Read in all of the CSS rules
css_rules_static=`cat rules.d/static.css`
css_rules_height=`cat rules.d/height.css`
css_rules_width=`cat rules.d/width.css`
css_rules_margin=`cat rules.d/margin.css`
css_rules_generic=`cat rules.d/generic.css`
css_rules_border=`cat rules.d/border.css`

# Read the config file, removing commented lines
css_config_sizes=`cat sizes.cfg | sed 's/^#.*//g'`

# Size mappings
css_size_prefix=( 'sm\\:' 'md\\:' 'lg\\:' )
css_size_rules=( '(max-width:600px) or (max-height:600px)' 'min-width:601px' 'min-width:1367px' )
css_size_count="${#css_size_prefix[@]}"

# Define the strings that are replaced with the rule values
css_macro_size='__SIZE__'
css_macro_name='__NAME__'
css_macro_value='__VALUE__'

# Define the output files that should be used
css_out_normal='simple.css'
css_out_minified='simple.min.css'
css_out_header="
/*
 * simple.css
 * Generated $(date)
 */
"

css_generated_rules=""
i=0
while [ $i -le $css_size_count ]; do
    sz="${css_size_prefix[i]}"
    css_rule="${css_size_rules[i]}"

    # Generate the media rule
    if [[ $i -lt $css_size_count ]]; then
        echo "Generating $(echo $sz | sed -e 's/\\\\/\\/g') rules"
        css_generated_rules+=`echo -e "\n@media only screen and ($css_rule) {\n" `
    else
        echo "Generating unsized rules"
    fi

    # Generate the classes for each config size
    for cfg in $css_config_sizes; do
        # Extract the config settings
        cfg_target=`echo "$cfg" | cut -d ',' -f 1`
        cfg_name=`echo "$cfg" | cut -d ',' -f 2`
        cfg_value=`echo "$cfg" | cut -d ',' -f 3`

        # Check for only target N for unused values
        if [[ "$cfg_target" == "N" ]]; then
            continue
        fi

        # Generate the width rules with target W (or A for all)
        if [[ "$cfg_target" == *"A"* || "$cfg_target" == *"W"* ]]; then
            rule=`echo "$css_rules_width" | sed "s/$css_macro_size/$sz/g"`
            rule=`echo "$rule" | sed "s/$css_macro_name/$cfg_name/g"`
            rule=`echo "$rule" | sed "s/$css_macro_value/$cfg_value/g"`
            css_generated_rules+=`echo -e "\n$rule "`
        fi

        # Generate the height rules with target H (or A for all)
        if [[ "$cfg_target" == *"A"* || "$cfg_target" == *"H"* ]]; then
            rule=`echo "$css_rules_height" | sed "s/$css_macro_size/$sz/g"`
            rule=`echo "$rule" | sed "s/$css_macro_name/$cfg_name/g"`
            rule=`echo "$rule" | sed "s/$css_macro_value/$cfg_value/g"`
            css_generated_rules+=`echo -e "\n$rule "`
        fi

        # Generate the margin rules with target M (or A for all)
        if [[ "$cfg_target" == *"A"* || "$cfg_target" == *"M"* ]]; then
            rule=`echo "$css_rules_margin" | sed "s/$css_macro_size/$sz/g"`
            rule=`echo "$rule" | sed "s/$css_macro_name/$cfg_name/g"`
            rule=`echo "$rule" | sed "s/$css_macro_value/$cfg_value/g"`
            css_generated_rules+=`echo -e "\n$rule "`
        fi

        # Generate the border rules with target B (or A for all)
        if [[ "$cfg_target" == *"A"* || "$cfg_target" == *"B"* ]]; then
            rule=`echo "$css_rules_border" | sed "s/$css_macro_size/$sz/g"`
            rule=`echo "$rule" | sed "s/$css_macro_name/$cfg_name/g"`
            rule=`echo "$rule" | sed "s/$css_macro_value/$cfg_value/g"`
            css_generated_rules+=`echo -e "\n$rule "`
        fi
    done
    
    # Generate the generic rules for items such as layouts
    rule=`echo "$css_rules_generic" | sed "s/$css_macro_size/$sz/g"`
    css_generated_rules+=`echo -e "\n$rule "`


    # Close the media rule
    if [[ $i -lt $css_size_count ]]; then
        css_generated_rules+=`echo "\n}\n"`
    fi
    ((i++))
done

echo -e "\nWriting to $css_out_normal"

css_out_rules=`echo -e "$css_out_header\n$css_rules_static\n$css_generated_rules"`
echo "$css_out_rules" > "$css_out_normal"

echo "Getting minified rules using the toptal css minifier"
css_out_rules_minified=`curl -X POST -s --data-urlencode "input@$css_out_normal" https://www.toptal.com/developers/cssminifier/raw`
echo "Writing to $css_out_minified"
echo "$css_out_rules_minified" > "$css_out_minified"