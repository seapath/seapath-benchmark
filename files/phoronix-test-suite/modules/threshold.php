<?php

/*
	Phoronix Test Suite
	URLs: http://www.phoronix.com, http://www.phoronix-test-suite.com/
	Copyright (C) 2008 - 2016, Phoronix Media
	Copyright (C) 2008 - 2016, Michael Larabel
	dummy_module.php: A simple 'dummy' module to demonstrate the PTS functions

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

class threshold extends pts_module_interface
{
	const module_name = 'Threshold';
	const module_version = '1.0';
	const module_description = 'This module is intended to test if a test result value exceed a threshold value.';
	const module_author = 'Savoir-faire Linux';

	private static $result_identifier;

	public static function add_to_result_file($r) {
		$pass_fail_result = null;

		if(empty($r) || !pts_types::is_result_file($r[0]))
		{
			echo 'No result file supplied.';
			return;
		}
        $threshold = $r[1];
		$result_file = new pts_result_file($r[0]);
		$result_file_identifiers = $result_file->get_system_identifiers();


        foreach($result_file->get_result_objects() as $result_object)
        {
            foreach($result_object->test_result_buffer->buffer_items as &$buffer)
            {
                $test_result_value = $buffer->get_result_value();
            }
            break;
        }

        if($test_result_value > $threshold) {
            $pass_fail_result = "FAIL";
        }
        else{
            $pass_fail_result = "PASS";
        }

		$test_profile = new pts_test_profile();
		$test_result = new pts_test_result($test_profile);
		$test_result->test_profile->set_test_title('Pass/Fail test threshold');
		$test_result->test_profile->set_identifier(null);
		$test_result->test_profile->set_version(null);
		$test_result->test_profile->set_display_format('PASS_FAIL');
		$result_file->add_result($test_result);
		$test_result->test_result_buffer = new pts_test_result_buffer();
		$test_result->test_result_buffer->add_test_result($test_result_value . '<' . $threshold, $pass_fail_result);
		pts_client::save_test_result($result_file->get_file_location(), $result_file->get_xml());

		echo $pass_fail_result . PHP_EOL;
    }

	public static function user_commands()
	{
		return array('add' => 'add_to_result_file');
	}
}

?>
